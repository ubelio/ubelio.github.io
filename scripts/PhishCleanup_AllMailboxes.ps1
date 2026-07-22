
<# ==============================================================================================
PhishCleanup_AllMailboxes.ps1
Purpose: Tenant-wide search & purge of phishing/compromised emails
Runner: Global Administrators ONLY (Purview roles already granted)
Design: PIM pre-flight (GA active), SCC delegated connection (-EnableSearchOnlySession),
        unique search names, safer KQL, typed confirmation, audit logging
Mode: Interactive-only (no parameters); Always Preview; Always Verbose polling
Pinned modules:
  - ExchangeOnlineManagement 3.9.0
  - Microsoft.Graph.Authentication 2.33.0
  - Microsoft.Graph.Users 2.33.0
  - Microsoft.Graph.Identity.Governance 2.33.0
Audit ledger UNC:
#unc path to the logs for reporting
ScriptVersion: 2025-12-15
============================================================================================== #>

# ----- Console helpers -----
function Write-Info     { param([string]$m) Write-Host $m -ForegroundColor Cyan }
function Write-Warn     { param([string]$m) Write-Host $m -ForegroundColor Yellow }
function Write-ErrorMsg { param([string]$m) Write-Host $m -ForegroundColor Red }
function Write-OK       { param([string]$m) Write-Host $m -ForegroundColor Green }

# ----- Interactive Prompts -----
function Prompt-Upn {
    do {
        $upn = Read-Host "Enter Global Admin UPN"
        $valid = $upn -match '^[^@\s]+@[^@\s]+\.[^@\s]+$'
        if (-not $valid) { Write-Warn "Invalid UPN format. Try again." }
    } until ($valid)
    return $upn
}
function Prompt-Email { param([string]$PromptText)
    do {
        $email = Read-Host $PromptText
        $valid = $email -match '^[^@\s]+@[^@\s]+\.[^@\s]+$'
        if (-not $valid) { Write-Warn "Invalid email format. Try again." }
    } until ($valid)
    return $email
}
function Prompt-Text  { param([string]$PromptText)
    do {
        $text = Read-Host $PromptText
        if ([string]::IsNullOrWhiteSpace($text)) { Write-Warn "Value cannot be empty." }
    } until (-not [string]::IsNullOrWhiteSpace($text))
    return $text
}
function Prompt-Date  { param([string]$PromptText)
    do {
        $d = Read-Host $PromptText
        $valid = $d -match '^\d{4}-\d{2}-\d{2}$'
        if (-not $valid) { Write-Warn "Use YYYY-MM-DD format." }
    } until ($valid)
    return $d
}

# ====== Always-on flags ======
$PreviewFirst = $true
$VerboseLog   = $true
Write-Info "Preview mode: ENABLED"
Write-Info "Verbose polling: ENABLED"

# ====== Gather inputs ======
$UserPrincipalName = Prompt-Upn
$From              = Prompt-Email "Sender email (exact)"
$Subject           = Prompt-Text "Subject (exact phrase)"
$StartDate         = Prompt-Date "Start date (YYYY-MM-DD)"
$EndDate           = Prompt-Date "End date   (YYYY-MM-DD)"

# ====== Validate date range ======
try {
    $start = [datetime]::ParseExact($StartDate,'yyyy-MM-dd',$null)
    $end   = [datetime]::ParseExact($EndDate,'yyyy-MM-dd',$null)
    if ($end -lt $start) { throw "EndDate ($EndDate) is earlier than StartDate ($StartDate)." }
}
catch {
    Write-ErrorMsg "Input validation failed: $($_.Exception.Message)"
    Start-Sleep -Seconds 60
    exit 1
}

# ====== Import required modules by explicit path (pinned versions) ======
try {
    # Exchange Online Management (pinned)
    Import-Module "C:\Program Files\WindowsPowerShell\Modules\ExchangeOnlineManagement\3.9.0\ExchangeOnlineManagement.psd1" -ErrorAction Stop

    # Microsoft Graph submodules pinned to 2.33.0 (avoid umbrella Microsoft.Graph)
    Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Authentication\2.33.0\Microsoft.Graph.Authentication.psd1" -ErrorAction Stop
    Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Users\2.33.0\Microsoft.Graph.Users.psd1" -ErrorAction Stop
    Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.Graph.Identity.Governance\2.33.0\Microsoft.Graph.Identity.Governance.psd1" -ErrorAction Stop

    Write-OK "Modules imported successfully (EOM 3.9.0, Graph 2.33.0)."
}
catch {
    Write-ErrorMsg "Module import failed: $($_.Exception.Message)"
    Start-Sleep -Seconds 60
    exit 1
}

# ====== PIM pre-flight — confirm Global Administrator is ACTIVE ======
function Test-PimGlobalAdminActive {
    param([string]$Upn)
    try {
        # Least-privileged scopes to read active assignments (delegated)
        Connect-MgGraph -Scopes "RoleAssignmentSchedule.Read.Directory","RoleManagement.Read.Directory" | Out-Null

        $ctx = Get-MgContext
        if (-not $ctx -or -not $ctx.Account) { throw "No Graph context/account after Connect-MgGraph." }

        $me     = Get-MgUser -UserId $ctx.Account
        $userId = $me.Id
        if (-not $userId) { throw "Unable to resolve current user's object ID." }

        $instances = Get-MgRoleManagementDirectoryRoleAssignmentScheduleInstance `
            -Filter "principalId eq '$userId'" `
            -ExpandProperty RoleDefinition -All

        $gaActive = $instances | Where-Object {
            $_.RoleDefinition.DisplayName -in @("Global Administrator","Company Administrator")
        }

        return [bool]$gaActive
    }
    catch {
        Write-Warn "PIM check issue: $($_.Exception.Message)"
        return $false
    }
}

Write-Info "Checking PIM elevation (Global Administrator active)..."
if (-not (Test-PimGlobalAdminActive -Upn $UserPrincipalName)) {
    Write-ErrorMsg "Global Administrator is NOT ACTIVE for $UserPrincipalName."
    Write-Warn "Activate GA via Microsoft Entra PIM (My roles), then rerun."
    Start-Sleep -Seconds 60
    exit 1
}
Write-OK "PIM check passed — GA is active."

# ====== Connect to Security & Compliance with -EnableSearchOnlySession ======
try {
    Write-Info "Connecting to SCC as $UserPrincipalName ..."
    Connect-IPPSSession -UserPrincipalName $UserPrincipalName -EnableSearchOnlySession -ErrorAction Stop
    Write-OK "Connected to SCC."
}
catch {
    Write-ErrorMsg "SCC connection failed: $($_.Exception.Message)"
    Write-ErrorMsg "Use delegated (interactive) auth"
    Start-Sleep -Seconds 60
    exit 1
}

# ====== Build safer KQL (tenant-wide) ======
try {
    $escapedSubject = $Subject.Replace('"','\"')
    $kql = "kind:email senderauthor=$From subject=`"$escapedSubject`" received=$StartDate..$EndDate"
    Write-Info "KQL query: $kql"
}
catch {
    Write-ErrorMsg "KQL build failed: $($_.Exception.Message)"
    Disconnect-ExchangeOnline -Confirm:$false
    Start-Sleep -Seconds 60
    exit 1
}

# ====== Create unique search (scope: All) and start ======
try {
    $timestamp = (Get-Date -Format "yyyyMMdd_HHmmss")
    $searchName = "PhishCleanup_${timestamp}"
    Write-Info "Creating compliance search '$searchName' (ALL mailboxes)..."
    New-ComplianceSearch -Name $searchName -ExchangeLocation "All" -ContentMatchQuery $kql -ErrorAction Stop
    Write-Info "Starting search..."
    Start-ComplianceSearch -Identity $searchName -ErrorAction Stop
    Write-OK "Search started."
}
catch {
    Write-ErrorMsg "Create/start search failed: $($_.Exception.Message)"
    Disconnect-ExchangeOnline -Confirm:$false
    Start-Sleep -Seconds 60
    exit 1
}

# ====== Poll until Completed (with timeout) and report items ======
try {
    $maxWaitSeconds = 20 * 60
    $pollInterval = 30
    $elapsed = 0
    Write-Info "Polling search status (up to $maxWaitSeconds seconds)..."
    do {
        Start-Sleep -Seconds $pollInterval
        $elapsed += $pollInterval
        $statusObj = Get-ComplianceSearch -Identity $searchName -ErrorAction Stop
        # Verbose polling always on
        Write-Info "Status: $($statusObj.Status); Items (estimate): $($statusObj.Items)"
    } while ($statusObj.Status -ne "Completed" -and $elapsed -lt $maxWaitSeconds)

    if ($statusObj.Status -ne "Completed") { throw "Search did not complete within $maxWaitSeconds seconds." }
    $itemsFound = $statusObj.Items
    Write-OK "Search '$searchName' completed. Estimated matches: $itemsFound"
}
catch {
    Write-ErrorMsg "Search polling failed: $($_.Exception.Message)"
    Disconnect-ExchangeOnline -Confirm:$false
    Start-Sleep -Seconds 60
    exit 1
}

# ====== Always Preview (non-destructive) ======
try {
    Write-Info "Creating preview action (non-destructive)..."
    New-ComplianceSearchAction -SearchName $searchName -Preview -ErrorAction Stop
    Write-OK "Preview action created. Review items in Purview."
}
catch {
    Write-Warn "Preview action failed: $($_.Exception.Message)"
    Write-Warn "Proceed carefully; confirm query accuracy before purge."
}

# ====== Typed confirmation + PURGE (SoftDelete) ======
if ($itemsFound -le 0) {
    Write-Warn "No items matched the search. Skipping purge."
}
else {
    Write-Warn "TENANT-WIDE PURGE: About to SOFT-DELETE $itemsFound item(s) matching:"
    Write-Warn " Sender: $From"
    Write-Warn " Subject: $Subject"
    Write-Warn " Dates: $StartDate..$EndDate"

    do {
        Write-Warn "Type exactly: PURGE-ALL, anything else will do nothing."
        $confirm = Read-Host "Confirm"

        if ($confirm -ne "PURGE-ALL") {
            Write-Warn "Invalid input. You must type: PURGE-ALL"
        }

    } until ($confirm -eq "PURGE-ALL")

    try {
        Write-Info "Submitting purge (SoftDelete)..."
        New-ComplianceSearchAction -SearchName $searchName -Purge -PurgeType SoftDelete -ErrorAction Stop
        Write-OK "Purge submitted."
    }
    catch {
        Write-ErrorMsg "Purge failed: $($_.Exception.Message)"
    }
}


# ====== Audit logging (CSV + JSON to UNC) ======
try {
    $actor = $UserPrincipalName
    $logRecord = [pscustomobject]@{
        Timestamp        = (Get-Date).ToString("o")
        ActorUPN         = $actor
        SearchName       = $searchName
        Scope            = "All mailboxes"
        From             = $From
        Subject          = $Subject
        Kql              = $kql
        StartDate        = $StartDate
        EndDate          = $EndDate
        ItemsEstimate    = $itemsFound
        PreviewRequested = $true
        PurgeConfirmed   = ($confirm -eq "PURGE-ALL")
        PurgeType        = if ($confirm -eq "PURGE-ALL") { "SoftDelete" } else { "None" }
        Machine          = $env:COMPUTERNAME
        ScriptVersion    = "2025-12-15"
    }

    $reportRoot = "" #unc path for reports

    # Optional: ensure directory exists (create if missing)
    if (-not (Test-Path -Path $reportRoot)) {
        Write-Warn "Report directory not found. Attempting to create: $reportRoot"
        New-Item -ItemType Directory -Path $reportRoot -Force | Out-Null
    }

    $csvPath  = Join-Path $reportRoot "PhishCleanup_Audit_${timestamp}.csv"
    $jsonPath = Join-Path $reportRoot "PhishCleanup_Audit_${timestamp}.json"

    if (-not (Test-Path $csvPath)) {
        $logRecord | Export-Csv -Path $csvPath -NoTypeInformation
    } else {
        $logRecord | Export-Csv -Path $csvPath -NoTypeInformation -Append
    }

    $logRecord | ConvertTo-Json -Depth 4 | Add-Content -Path $jsonPath
    Write-OK "Audit saved: $csvPath; $jsonPath"
}
catch {
    Write-Warn "Audit logging failed: $($_.Exception.Message)"
}

# ====== Disconnect SCC / Graph ======
try { Disconnect-ExchangeOnline -Confirm:$false } catch { }
try { Disconnect-MgGraph | Out-Null } catch { }

# ====== Require user to type something specific before closing, eliminates accidental ENTER presse ====== 
$confirmation = Read-Host "Type 'YES' to exit"
while ($confirmation -ne "YES") {$confirmation = Read-Host "Invalid input. Please type 'YES' to exit"}
