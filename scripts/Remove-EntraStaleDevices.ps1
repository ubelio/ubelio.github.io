<#
.SYNOPSIS
  Microsoft Entra device lifecycle automation (certificate-based, app-only Graph auth):
  - Auto-delete devices with activity older than $StaleMonths months
  - EXCLUDES devices that are direct members of a specified Entra group (completely ignored)
  - Persist a ledger CSV and produce a run-specific CSV report
  - Optional summary email with a "No stale devices found" banner

.DESCRIPTION
  Connects to Microsoft Graph using certificate-based authentication and performs a scheduled cleanup by
  identifying devices whose approximateLastSignInDateTime is older than the cutoff and deleting them.

  Fallback: If approximateLastSignInDateTime is null, uses createdDateTime < cutoff.

  EXCLUSION BEHAVIOR:
  - Devices that are direct members of $ExcludeGroupId are completely ignored:
      * not deleted
      * not included in report
      * not included in ledger
      * not counted
  - If exclusion membership cannot be retrieved and $StopRunIfExclusionLookupFails is $true,
    the run stops before enumerating any devices and writes a single-line failure report.
    This is a deliberate fail-closed design: if the protection list cannot be read,
    nothing is deleted.

.NOTES
  Requires an Entra app registration with application (app-only) Graph permissions:
    - Device.ReadWrite.All        (enumerate and delete devices)
    - GroupMember.Read.All        (read exclusion group membership)
    - Mail.Send                   (optional, only if email summary is used)
    - Organization.Read.All       (optional, used for tenant display name in report filename)
  Admin consent must be granted for each.

  The certificate used for authentication must be installed in the certificate store
  of the account running the script (typically a scheduled task service account).

  Run with $WhatIf = $true first to preview what would be deleted.
#>

# ============================
# CONFIGURATION (edit here)
# ============================

# Entra app registration & certificate (app-only auth)
$TenantId       = ""   # Your Entra tenant ID (GUID)
$ClientId       = ""   # App registration (client) ID (GUID)
$CertThumbprint = ""   # Thumbprint of the auth certificate installed on this machine

# Staleness policy (months)
# Devices with no activity older than this threshold are considered stale.
$StaleMonths = 12

# Optional scope filter for trust type (keep 'All' to include everything)
# 'AzureAd' = Entra joined | 'Workplace' = Entra registered | 'ServerAd' = Hybrid joined
$TrustScope = 'All'   # 'All' | 'AzureAd' | 'Workplace' | 'ServerAd'

# Output location for the ledger and per-run CSV reports (UNC recommended)
$ReportFolder = ""   # e.g. \\server\share\EntraDeviceCleanup

# Email summary (leave $NotificationTo blank to skip)
$NotificationTo = ""   # Recipient address for the run summary
$SenderUpn      = ""   # UPN of the mailbox used to send (requires Mail.Send)

# Safe audit mode (no changes). Set $true for dry runs.
$WhatIf = $false

# ============================
# EXCLUSION GROUP (direct membership only)
# ============================
# Devices that are DIRECT members of this Entra group will be completely ignored
# (not deleted, not reported, not written to ledger, not counted).
# Use this for devices that are legitimately inactive for long periods but must
# remain available on demand (for example, shared or standby devices).
$ExcludeGroupId = ""   # Object ID (GUID) of the Entra group holding protected devices

# Safety: if exclusion membership lookup fails, STOP the run before enumerating devices.
# Leave this $true so a failed protection lookup can never result in deletions.
$StopRunIfExclusionLookupFails = $true

# ============================
# MODULE IMPORTS (explicit, silent)
# ============================
# Imported by explicit path so the scheduled task loads a known module version
# rather than whatever happens to resolve first. Adjust versions to match your environment.

Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Authentication\2.33.0\Microsoft.Graph.Authentication.psd1" -ErrorAction Stop
Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Identity.DirectoryManagement\2.33.0\Microsoft.Graph.Identity.DirectoryManagement.psd1" -ErrorAction Stop
Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Users.Actions\2.33.0\Microsoft.Graph.Users.Actions.psd1" -ErrorAction Stop
Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Groups\2.33.0\Microsoft.Graph.Groups.psd1" -ErrorAction Stop

# ============================
# UTILITIES & SETUP
# ============================

function New-Timestamp { (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss') }

function Get-ExcludedDeviceIdSet {
  <#
    Returns a case-insensitive HashSet of device object IDs that are DIRECT members
    of the supplied group. Nested groups are intentionally not expanded.
  #>
  param(
    [Parameter(Mandatory = $true)][string]$GroupId
  )

  $set = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

  # Direct membership only
  $members = Get-MgGroupMember -GroupId $GroupId -All -Property "id" -ErrorAction Stop

  foreach ($m in $members) {
    $odataType = $null
    if ($m.PSObject.Properties.Name -contains 'AdditionalProperties') {
      $odataType = $m.AdditionalProperties['@odata.type']
    }

    # Only collect device objects (the group may also contain users or other types)
    if ($odataType -eq '#microsoft.graph.device' -and $m.Id) {
      [void]$set.Add($m.Id)
    }
  }

  return $set
}

if (-not (Test-Path $ReportFolder)) { New-Item -ItemType Directory -Path $ReportFolder -Force | Out-Null }

# The ledger is a running historical record across all runs, so previously deleted
# devices remain auditable long after their per-run report has been archived.
$ledgerPath = Join-Path $ReportFolder 'DeviceLifecycleLedger.csv'
if (-not (Test-Path $ledgerPath)) {
  "DeviceId,DisplayName,DisabledOn,DeletedOn,LastSignIn,CreatedOn,TrustType,OperatingSystem" | Out-File -FilePath $ledgerPath -Encoding utf8
}

# ============================
# LEDGER LOAD
#  - Force Import-Csv to always return an array, even with a single row,
#    otherwise adding to it later throws an op_Addition error.
# ============================
$ledger = @()
try {
  $ledger = @(Import-Csv -Path $ledgerPath)
} catch {
  # If ledger is unreadable for any reason, start with empty in-memory ledger
  $ledger = @()
}

# ============================
# CONNECT (cert-based, app-only)
# ============================
# No interactive sign-in and no stored secret: authentication uses the certificate
# thumbprint, which suits an unattended scheduled task.

Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -CertificateThumbprint $CertThumbprint -NoWelcome

# ============================
# REPORT NAMING & TIME ANCHOR
# ============================

$ts        = New-Timestamp
$now       = Get-Date
$cutoffUtc = (Get-Date).AddMonths(-$StaleMonths).ToUniversalTime()

# Use UTC 'Z' timestamp for Graph filter to avoid timezone parsing issues
$cutoffIso = $cutoffUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")

$tenantName = 'Tenant'
try { $tenantName = (Get-MgOrganization -ErrorAction Stop).DisplayName } catch {}

$reportPath = Join-Path $ReportFolder ("Entra_StaleDevice_AutoDelete_{0}_{1}.csv" -f $tenantName, $ts)
$reportRows = @()

# ============================
# BUILD EXCLUSION SET (protected devices)
#  - Fail-closed: stop run if lookup fails, BEFORE enumerating any devices
# ============================

$SkipDeviceProcessing = $false
$excludedDeviceIds    = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

if ($ExcludeGroupId) {
  try {
    $excludedDeviceIds = Get-ExcludedDeviceIdSet -GroupId $ExcludeGroupId
  } catch {
    if ($StopRunIfExclusionLookupFails) {
      $SkipDeviceProcessing = $true

      $reportRows = @(
        [pscustomobject]@{
          Timestamp       = $now.ToString("s")
          DeviceId        = ""
          DisplayName     = ""
          OperatingSystem = ""
          TrustType       = $TrustScope
          LastSignIn      = ""
          CreatedOn       = ""
          Action          = "None"
          ActionStatus    = "ExclusionLookupFailed"
          Notes           = "Stopped run: could not read exclusion group membership. Verify app permissions (GroupMember.Read.All or Group.Read.All - Application) and admin consent."
        }
      )

      $reportRows | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
    }
  }
}

# ============================
# MAIN PROCESSING (stale discovery + deletion)
# ============================

$deletedCount = 0

if (-not $SkipDeviceProcessing) {

  # ============================
  # QUERY STALE DEVICES (Graph-side filter + client-side fallback)
  # ============================

  # Pass 1: let Graph filter on last sign-in. This is the fast path.
  $staleBySignIn = @()
  try {
    $staleBySignIn = Get-MgDevice -Property "id,displayName,approximateLastSignInDateTime,createdDateTime,trustType,operatingSystem,accountEnabled" `
                                  -ConsistencyLevel 'eventual' -CountVariable null `
                                  -Filter ("approximateLastSignInDateTime lt {0}" -f $cutoffIso) `
                                  -All -ErrorAction Stop
  } catch { }  # Silent; continue to fallback

  # Pass 2: devices that have NEVER signed in report a null last sign-in and are
  # therefore missed by the filter above. Catch them using creation date instead.
  $noSignInOlderThanCutoff = @()
  try {
    $allCandidates = Get-MgDevice -Property "id,displayName,approximateLastSignInDateTime,createdDateTime,trustType,operatingSystem,accountEnabled" -All -ErrorAction Stop
    $noSignInOlderThanCutoff = $allCandidates | Where-Object {
      -not $_.ApproximateLastSignInDateTime -and $_.CreatedDateTime -lt $cutoffUtc
    }
  } catch { }

  # Merge & de-dup (a device can legitimately appear in both passes)
  $staleAll = @(
    $staleBySignIn
    $noSignInOlderThanCutoff
  ) | Where-Object { $_ } | Group-Object Id | ForEach-Object { $_.Group[0] }

  # Optional trust-type scope
  if ($TrustScope -ne 'All') {
    $staleAll = $staleAll | Where-Object { $_.TrustType -eq $TrustScope }
  }

  # ============================
  # EXCLUDE PROTECTED DEVICES (no report, no delete, no ledger, no count)
  # ============================
  if ($ExcludeGroupId -and $excludedDeviceIds.Count -gt 0) {
    $staleAll = $staleAll | Where-Object { -not $excludedDeviceIds.Contains($_.Id) }
  }

  # ============================
  # DELETE PHASE (auto-delete)
  # ============================

  foreach ($dv in $staleAll) {

    $row = [pscustomobject]@{
      Timestamp       = $now.ToString("s")
      DeviceId        = $dv.Id
      DisplayName     = $dv.DisplayName
      OperatingSystem = $dv.OperatingSystem
      TrustType       = $dv.TrustType
      LastSignIn      = $dv.ApproximateLastSignInDateTime
      CreatedOn       = $dv.CreatedDateTime
      Action          = "Delete"
      ActionStatus    = ""
      Notes           = ""
    }

    if ($WhatIf) {
      $row.ActionStatus = "WhatIf"
      $row.Notes        = "Would delete"
      $reportRows += $row
      continue
    }

    # ============================
    # Deletion and ledger update are handled separately so a successful delete
    # is never misreported as an error just because the ledger write failed.
    # ============================
    $deletedOk = $false

    # 1) Delete device
    try {
      Remove-MgDevice -DeviceId $dv.Id -ErrorAction Stop
      $deletedOk = $true
      $deletedCount++
      $row.ActionStatus = "Success"
      $row.Notes        = "Deleted"
    } catch {
      $row.ActionStatus = "Error"
      $row.Notes        = "Delete failed: " + $_.Exception.Message
    }

    # 2) Update ledger only if delete succeeded
    if ($deletedOk) {
      try {
        $existing  = $ledger | Where-Object { $_.DeviceId -eq $dv.Id }
        $deletedOn = $now.ToString("s")

        if ($existing) {
          $existing | ForEach-Object {
            $_.DeletedOn       = $deletedOn
            $_.DisplayName     = $dv.DisplayName
            $_.LastSignIn      = $dv.ApproximateLastSignInDateTime
            $_.CreatedOn       = $dv.CreatedDateTime
            $_.TrustType       = $dv.TrustType
            $_.OperatingSystem = $dv.OperatingSystem
          }
        } else {
          $ledger += [pscustomobject]@{
            DeviceId        = $dv.Id
            DisplayName     = $dv.DisplayName
            DisabledOn      = ""   # Not used in this policy; column retained for compatibility
            DeletedOn       = $deletedOn
            LastSignIn      = $dv.ApproximateLastSignInDateTime
            CreatedOn       = $dv.CreatedDateTime
            TrustType       = $dv.TrustType
            OperatingSystem = $dv.OperatingSystem
          }
        }
      } catch {
        # Keep ActionStatus as Success because deletion happened; just note ledger issue
        $row.Notes = "Deleted; ledger update failed: " + $_.Exception.Message
      }
    }

    $reportRows += $row
  }

  # Defensive writes (quiet)
  $reportRows | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
  $ledger     | Export-Csv -Path $ledgerPath -NoTypeInformation -Encoding UTF8

  # ============================
  # FINALIZE REPORT (clarity when none deleted)
  #  - Write an explicit "nothing to do" row so an empty report is never
  #    mistaken for a failed run.
  # ============================

  if (($deletedCount -eq 0) -and ($null -eq $reportRows -or $reportRows.Count -eq 0)) {
    $reportRows = @(
      [pscustomobject]@{
        Timestamp       = $now.ToString("s")
        DeviceId        = ""
        DisplayName     = "No stale devices found this run"
        OperatingSystem = ""
        TrustType       = $TrustScope
        LastSignIn      = ""
        CreatedOn       = ""
        Action          = "None"
        ActionStatus    = "NoStaleDevicesFound"
        Notes           = "No devices met the policy (Activity older than $StaleMonths months)"
      }
    )
    $reportRows | Export-Csv -Path $reportPath -NoTypeInformation -Encoding UTF8
  }
}

# ============================
# EMAIL SUMMARY (HTML with banner when applicable)
# ============================

if ($NotificationTo -and $SenderUpn) {
  try {
    $deletedRows = $reportRows | Where-Object { $_.Action -eq 'Delete' -and $_.ActionStatus -eq 'Success' }

    # Banner makes the three outcomes (stopped / nothing to do / deletions) obvious
    # at a glance without opening the attached CSV.
    $banner = ""
    $subjectSuffix = ""

    if ($SkipDeviceProcessing) {
      $banner = "<p style='padding:10px;border:1px solid #d32f2f;background:#ffebee;color:#b71c1c'><strong>Run stopped:</strong> exclusion group membership could not be retrieved. No device enumeration or deletions were performed.</p>"
      $subjectSuffix = " (Stopped - exclusion lookup failed)"
    }
    elseif ($deletedCount -eq 0) {
      $banner = "<p style='padding:10px;border:1px solid #4CAF50;background:#e9f7ef;color:#2e7d32'><strong>No stale devices found this run.</strong></p>"
      $subjectSuffix = " (No stale devices)"
    }

    $deletedTable = "<table border='1' cellspacing='0' cellpadding='4'><tr><th>Hostname</th><th>Last Activity</th><th>Created</th><th>OS</th><th>TrustType</th></tr>"
    foreach ($dr in $deletedRows) {
      $deletedTable += "<tr><td>$($dr.DisplayName)</td><td>$($dr.LastSignIn)</td><td>$($dr.CreatedOn)</td><td>$($dr.OperatingSystem)</td><td>$($dr.TrustType)</td></tr>"
    }
    $deletedTable += "</table>"

    $html = @"
<html>
  <body>
    $banner
    <p><strong>Entra Device Cleanup   $($now.ToString('yyyy-MM-dd'))</strong></p>
    <ul>
      <li>Deleted: <strong>$deletedCount</strong></li>
      <li>Policy: Activity older than $StaleMonths months</li>
      <li>Trust scope: $TrustScope</li>
      <li>Report: $(Split-Path -Leaf $reportPath)</li>
    </ul>
    <h3>Deleted Devices</h3>
    $deletedTable
    <p>See attached CSV for full details.</p>
  </body>
</html>
"@

    $attachmentB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($reportPath))
    $mailBody = @{
      Message = @{
        Subject = "Entra Device Cleanup   $($now.ToString('yyyy-MM-dd'))$subjectSuffix"
        Body    = @{ ContentType = "HTML"; Content = $html }
        ToRecipients = @(@{ EmailAddress = @{ Address = $NotificationTo } })
        Attachments  = @(@{
          "@odata.type" = "#microsoft.graph.fileAttachment"
          Name          = [IO.Path]::GetFileName($reportPath)
          ContentBytes  = $attachmentB64
        })
      }
      SaveToSentItems = $true
    }

    if (-not $WhatIf) {
      Send-MgUserMail -UserId $SenderUpn -BodyParameter $mailBody -ErrorAction Stop
    }
  } catch {
    # Silent failure; see CSV output if needed.
  }
}