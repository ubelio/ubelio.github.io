#requires -Version 5.1
###############################################################################
# File Share -> SharePoint Sync (PRODUCTION)
#
# PURPOSE
#   - Monitor FIRST-LEVEL folders under a UNC path
#   - Upload NEW + UPDATED files to a SharePoint Online document library
#   - Preserve folder structure exactly
#   - Skip locked/in-use files (retry next run)
#   - Block only obvious temp files
#   - Track upload state locally (idempotent, safe re-runs)
#   - Email owners if SAME file fails 3 consecutive runs
#
# AUTHENTICATION
#   - App-only Microsoft Entra ID authentication
#   - Certificate-based
#   - PnP.PowerShell for SharePoint
#   - Microsoft Graph SDK for email (Send-MgUserMail)
#
# REQUIREMENTS
#   SharePoint (app-only, certificate auth via PnP):
#     - Sites.Selected (granted on the target site) or Sites.ReadWrite.All
#   Microsoft Graph (application permission, admin consent required):
#     - Mail.Send   (failure notifications only)
#   Modules: PnP.PowerShell, Microsoft.Graph.Authentication,
#            Microsoft.Graph.Users.Actions
#
#   The auth certificate must be installed in the certificate store of the
#   account running the script (typically a scheduled task service account).
#   The service account also needs read access to the source UNC path.
###############################################################################

# Enforce strict scripting rules to prevent silent bugs
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ============================================================================
# CONFIG (ONLY EDIT THIS SECTION)
# ============================================================================

# UNC container folder (folders INSIDE this are synced)
$RootContainer = ""          # e.g. \\server\share\DepartmentFiles

# SharePoint target site
$SiteUrl = ""                # e.g. https://contoso.sharepoint.com/sites/YourSite

# Target document library (display name)
$DestinationLibrary = ""     # e.g. Shared Documents

# Entra ID app details
$TenantId   = ""             # Entra tenant ID (GUID)
$Tenant     = ""             # Tenant domain, e.g. contoso.onmicrosoft.com
$ClientId   = ""             # App registration (client) ID
$Thumbprint = ""             # Thumbprint of the auth certificate on this machine

# Base working directory (holds state file and logs)
$BasePath = ""               # e.g. C:\Scripts\FileShareSync

# State + logging
$StateFile = Join-Path $BasePath "State.json"
$LogDir    = Join-Path $BasePath "Logs"

# Email notification recipients (after 3 consecutive failures)
$NotifyTo   = @(
    "",
    ""
)

# Graph sender (must be mailbox-enabled and allowed for app Mail.Send)
$GraphMailFrom = ""

# Temp file filtering
$BlockedNamePrefixes = @("~$")
$BlockedExtensions   = @(".tmp", ".part")

# ============================================================================
# END CONFIG
# ============================================================================

# Ensure directories exist
New-Item -ItemType Directory -Path $BasePath -Force | Out-Null
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

# Create a per-run log file
$RunStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile  = Join-Path $LogDir "Run_$RunStamp.log"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")] $Level = "INFO"
    )
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path $LogFile -Value $line
}

# ----------------------------------------------------------------------------
# Helper: Detect obvious temp files
# Office creates ~$ lock files and .tmp/.part artifacts that must never sync.
# ----------------------------------------------------------------------------
function Is-TempFile {
    param([System.IO.FileInfo]$File)

    foreach ($prefix in $BlockedNamePrefixes) {
        if ($File.Name.StartsWith($prefix, 'OrdinalIgnoreCase')) {
            return $true
        }
    }

    if ($BlockedExtensions -contains $File.Extension.ToLowerInvariant()) {
        return $true
    }

    return $false
}

# ----------------------------------------------------------------------------
# Helper: Detect locked/in-use files
# Attempts an exclusive read. If the file is open by a user, this throws and we
# skip it, leaving it to be picked up on a later run rather than failing the sync.
# ----------------------------------------------------------------------------
function Test-FileLocked {
    param([string]$Path)

    try {
        $stream = [System.IO.File]::Open(
            $Path,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::None
        )
        $stream.Close()
        return $false
    }
    catch {
        return $true
    }
}

# ----------------------------------------------------------------------------
# Convert a PSCustomObject (from ConvertFrom-Json) into a Hashtable.
# ConvertFrom-Json returns PSCustomObject, which does NOT support ContainsKey(),
# Remove(), or index assignment. Normalizing on load guarantees state round-trips
# through JSON without breaking hashtable operations later in the run.
# ----------------------------------------------------------------------------
function ConvertTo-Hashtable {
    param([object]$InputObject)

    # Null -> empty hashtable
    if ($null -eq $InputObject) { return @{} }

    # Already a hashtable or dictionary -> return as a hashtable
    if ($InputObject -is [System.Collections.IDictionary]) {
        $ht = @{}
        foreach ($k in $InputObject.Keys) {
            $ht[$k] = $InputObject[$k]
        }
        return $ht
    }

    # PSCustomObject -> enumerate properties
    $ht2 = @{}
    foreach ($p in $InputObject.PSObject.Properties) {
        $ht2[$p.Name] = $p.Value
    }
    return $ht2
}

# ----------------------------------------------------------------------------
# Load / Save state (JSON)
# ----------------------------------------------------------------------------
function Load-State {
    if (Test-Path $StateFile) {
        $raw = Get-Content $StateFile -Raw | ConvertFrom-Json

        # Normalize to real hashtables so indexing always works
        $files    = ConvertTo-Hashtable $raw.Files
        $failures = ConvertTo-Hashtable $raw.Failures

        return [pscustomobject]@{
            Files    = $files
            Failures = $failures
        }
    }

    return [pscustomobject]@{
        Files    = @{}   # hashtable
        Failures = @{}   # hashtable
    }
}

function Save-State {
    param($State)
    $State | ConvertTo-Json -Depth 8 | Set-Content $StateFile -Encoding UTF8
}

# ----------------------------------------------------------------------------
# Send email using Microsoft Graph (NO SMTP)
# ----------------------------------------------------------------------------
function Send-FailureEmailGraph {
    param(
        [string]$FromUser,
        [string[]]$To,
        [string]$Subject,
        [string]$Body
    )

    try {
        $recipients = foreach ($addr in $To) {
            @{
                emailAddress = @{ address = $addr }
            }
        }

        $message = @{
            subject = $Subject
            body = @{
                contentType = "Text"
                content     = $Body
            }
            toRecipients = $recipients
        }

        Send-MgUserMail `
            -UserId $FromUser `
            -Message $message `
            -SaveToSentItems:$false

        Write-Log "Graph email sent to $($To -join ', ')" "INFO"
    }
    catch {
        Write-Log "Graph email FAILED: $($_.Exception.Message)" "ERROR"
    }
}

# ============================================================================
# MAIN
# ============================================================================
Write-Log "===== RUN START =====" "INFO"

$State = Load-State

# Connect to SharePoint (PnP)
# Modules are imported by explicit path so the scheduled task loads a known
# version rather than whatever resolves first. Adjust versions to your environment.
Import-Module "C:\Program Files\WindowsPowerShell\Modules\pnp.powershell.1.12.0\PnP.PowerShell.psd1" -Force
Connect-PnPOnline -Url $SiteUrl -Tenant $Tenant -ClientId $ClientId -Thumbprint $Thumbprint

# Connect to Graph ONCE (used only if failures occur)
Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Authentication\2.32.0\Microsoft.Graph.Authentication.psd1" -Force
Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Users.Actions\2.32.0\Microsoft.Graph.Users.Actions.psd1" -Force
Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $Thumbprint

$TopFolders = Get-ChildItem -Path $RootContainer -Directory

foreach ($Folder in $TopFolders) {

    $SourceRoot = $Folder.FullName
    $FolderName = $Folder.Name

    Write-Log "Scanning folder: $FolderName" "INFO"

    $Files = Get-ChildItem -Path $SourceRoot -File -Recurse -ErrorAction SilentlyContinue

    foreach ($File in $Files) {

        if (Is-TempFile $File) { continue }
        if (Test-FileLocked $File.FullName) { continue }

        # Change detection: path + last-write time + size. Cheaper than hashing
        # the file contents and sufficient to catch new and modified files.
        $Signature = "$($File.FullName)|$($File.LastWriteTimeUtc.Ticks)|$($File.Length)"

        # Hashtable-safe lookup: skip files whose signature is unchanged since
        # the last successful upload, which makes re-runs idempotent.
        if ($State.Files.ContainsKey($File.FullName) -and $State.Files[$File.FullName] -eq $Signature) {
            continue
        }

        # Rebuild the relative path so the destination mirrors the source tree exactly
        $RelativePath = $File.FullName.Substring($SourceRoot.Length).TrimStart('\')
        $RelativeDir  = Split-Path $RelativePath -Parent

        $DestFolder = "$DestinationLibrary/$FolderName"
        if ($RelativeDir -and $RelativeDir -ne ".") {
            $DestFolder = "$DestFolder/$($RelativeDir -replace '\\','/')"
        }

        try {
            Add-PnPFile -Path $File.FullName -Folder $DestFolder -ErrorAction Stop | Out-Null

            # Record the signature so this file is skipped until it changes again
            $State.Files[$File.FullName] = $Signature

            # Clear any prior failure count now that the file uploaded successfully
            if ($State.Failures.ContainsKey($File.FullName)) {
                $null = $State.Failures.Remove($File.FullName)
            }

            Write-Log "Uploaded: $($File.FullName)" "INFO"
        }
        catch {
            $ErrorMsg = $_.Exception.Message
            Write-Log "Upload FAILED: $($File.FullName) :: $ErrorMsg" "ERROR"

            # Use ContainsKey rather than truthiness so a zero count is handled correctly
            if (-not $State.Failures.ContainsKey($File.FullName)) {
                $State.Failures[$File.FullName] = [pscustomobject]@{ Count = 0 }
            }

            $State.Failures[$File.FullName].Count++

            # Alert only when the SAME file has failed three consecutive runs.
            # Transient failures self-resolve and never generate noise.
            if ($State.Failures[$File.FullName].Count -eq 3) {
                Send-FailureEmailGraph `
                    -FromUser $GraphMailFrom `
                    -To $NotifyTo `
                    -Subject "File Share to SharePoint Sync - File failed 3 times" `
                    -Body "File: $($File.FullName)`nError: $ErrorMsg"
            }
        }
    }
}

Save-State $State
Write-Log "===== RUN END =====" "INFO"
