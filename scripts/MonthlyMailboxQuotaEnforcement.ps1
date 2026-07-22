# ========================================================================================
# MAILBOX QUOTA MANAGEMENT SCRIPT (MONTHLY)
# ========================================================================================
# PURPOSE:
# This script enforces mailbox quota policies in Exchange Online.
# It:
#   1. Connects using secure app-only authentication (no user login required)
#   2. Applies quota rules based on group membership
#   3. ONLY changes mailboxes if they are incorrect (no unnecessary updates)
#   4. Tracks ALL changes made
#   5. Sends an email report with what changed
#   6. Saves a CSV file for audit purposes
#
# SAFE DESIGN:
# - Does NOT blindly overwrite mailboxes
# - Only applies changes when needed
# - Logs everything
# - Continues even if one mailbox fails
#
# REQUIREMENTS:
#   Exchange Online (app-only, certificate auth):
#     - Exchange.ManageAsApp application permission
#     - A directory role allowing mailbox management (e.g. Exchange Administrator)
#       assigned to the app registration
#   Microsoft Graph (application permission, admin consent required):
#     - Mail.Send   (send the report)
#   Modules: ExchangeOnlineManagement, Microsoft.Graph.Authentication,
#            Microsoft.Graph.Users.Actions
#
#   The auth certificate must be installed in the certificate store of the
#   account running the script (typically a scheduled task service account).
# ========================================================================================


# =============================
# CONFIGURATION SECTION
# =============================
# These values are used to authenticate to Microsoft services

$AppId      = ""   # Entra app registration (client) ID
$TenantId   = ""   # Entra tenant ID
$Thumbprint = ""   # Thumbprint of the auth certificate installed on this machine
$Org        = ""   # Exchange tenant domain, e.g. contoso.onmicrosoft.com

# Email settings (who gets the report)
$Sender     = ""             # UPN of the sending mailbox (requires Mail.Send)
$Recipients = @("", "")      # One or more recipient addresses
$Subject    = "Monthly Mailbox Quota Changes"
$IntroBody  = "Monthly mailbox quota enforcement report."

# Where logs and CSV reports go
$ReportFolder = ""           # UNC or local path for reports, e.g. \\server\share\QuotaReports
$SendEmailWhenNoChanges = $true

# Exception group names (distribution groups holding users with raised limits)
$Tier1GroupName = ""         # e.g. "Storage Limit Exceptions - Tier 1"
$Tier2GroupName = ""         # e.g. "Storage Limit Exceptions - Tier 2"

# Quota policy definitions: IssueWarning / ProhibitSend / ProhibitSendReceive
$DefaultQuotas = @{ Warn = "23GB"; Send = "25GB"; SendReceive = "50GB"  }
$Tier1Quotas   = @{ Warn = "48GB"; Send = "50GB"; SendReceive = "100GB" }
$Tier2Quotas   = @{ Warn = "72GB"; Send = "75GB"; SendReceive = "100GB" }
$SharedQuotas  = @{ Warn = "48GB"; Send = "50GB"; SendReceive = "50GB"  }


# =============================
# PREP WORK
# =============================
# This just sets up logging and ensures folders exist

$ErrorActionPreference = "Stop"
$RunTime = Get-Date
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

if (-not (Test-Path $ReportFolder)) {
    New-Item -ItemType Directory -Path $ReportFolder -Force | Out-Null
}

$CsvPath = Join-Path $ReportFolder "MailboxQuotaChanges_$TimeStamp.csv"
$LogPath = Join-Path $ReportFolder "MailboxQuotaRun_$TimeStamp.log"

Start-Transcript -Path $LogPath -Force

# Arrays used to track what happened
$Changes = @()   # successful changes
$Errors  = @()   # failures


# =============================
# HELPER FUNCTIONS
# =============================

# Converts quota values into a clean comparable format.
# Exchange returns values like "25 GB (26,843,545,600 bytes)", so strip the
# byte count and whitespace before comparing against the desired value.
function Normalize-QuotaValue {
    param ($Value)
    if ($null -eq $Value) { return "" }
    return ($Value.ToString().Split("(")[0]).Trim().Replace(" ", "")
}

# Stores a successful change in memory
function Add-ChangeRecord {
    param ($Mailbox,$DisplayName,$Category,$OldWarning,$NewWarning,$OldSend,$NewSend,$OldSR,$NewSR)

    $script:Changes += [PSCustomObject]@{
        Mailbox = $Mailbox
        DisplayName = $DisplayName
        Category = $Category
        OldWarning = $OldWarning
        NewWarning = $NewWarning
        OldSend = $OldSend
        NewSend = $NewSend
        OldSendReceive = $OldSR
        NewSendReceive = $NewSR
        Timestamp = Get-Date
    }
}

# Stores an error if something fails
function Add-ErrorRecord {
    param ($Target,$Category,$ErrorMsg)

    $script:Errors += [PSCustomObject]@{
        Target = $Target
        Category = $Category
        Error = $ErrorMsg
        Timestamp = Get-Date
    }
}

# This is the CORE LOGIC:
# - Reads mailbox
# - Compares existing quotas vs desired quotas
# - Updates ONLY if different
# A per-mailbox try/catch means one failure is recorded and skipped rather than
# ending the run, so a single problem mailbox cannot stop the whole enforcement pass.
function Set-MailboxQuotaIfNeeded {
    param ($Identity,$Category,$Warn,$Send,$SendReceive)

    try {
        $mb = Get-Mailbox -Identity $Identity

        $oldWarn = Normalize-QuotaValue $mb.IssueWarningQuota
        $oldSend = Normalize-QuotaValue $mb.ProhibitSendQuota
        $oldSR   = Normalize-QuotaValue $mb.ProhibitSendReceiveQuota

        $newWarn = Normalize-QuotaValue $Warn
        $newSend = Normalize-QuotaValue $Send
        $newSR   = Normalize-QuotaValue $SendReceive

        # Only act if something is different
        if ($oldWarn -ne $newWarn -or $oldSend -ne $newSend -or $oldSR -ne $newSR) {

            Set-Mailbox -Identity $Identity `
                -IssueWarningQuota $Warn `
                -ProhibitSendQuota $Send `
                -ProhibitSendReceiveQuota $SendReceive

            Add-ChangeRecord $mb.PrimarySmtpAddress $mb.DisplayName $Category $oldWarn $newWarn $oldSend $newSend $oldSR $newSR

            Write-Host "UPDATED [$Category] $($mb.PrimarySmtpAddress)" -ForegroundColor Yellow
        }
        else {
            Write-Host "NO CHANGE [$Category] $($mb.PrimarySmtpAddress)" -ForegroundColor DarkGray
        }
    }
    catch {
        Add-ErrorRecord $Identity $Category $_.Exception.Message
    }
}


# =============================
# CONNECT TO SERVICES
# =============================

# Connect to Exchange
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -AppId $AppId -CertificateThumbprint $Thumbprint -Organization $Org -ShowBanner:$false

# Connect to Graph (for sending email)
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users.Actions
Connect-MgGraph -ClientId $AppId -TenantId $TenantId -CertificateThumbprint $Thumbprint -NoWelcome


try {

    # ========================================================================================
    # PART 1 - STANDARD USERS (DEFAULT POLICY)
    # ========================================================================================
    # These are regular users NOT in any exception group

    $excludeGroups = $Tier1GroupName, $Tier2GroupName

    $excludedUsers = @()
    foreach ($group in $excludeGroups) {
        $excludedUsers += Get-DistributionGroupMember $group | Select-Object -Expand PrimarySmtpAddress
    }

    # Get only "normal" user mailboxes.
    # Shared, room, and equipment mailboxes are handled separately or not at all.
    $mailboxes = Get-Mailbox | Where-Object {
        $_.PrimarySmtpAddress -notin $excludedUsers -and
        $_.RecipientTypeDetails -notin @("SharedMailbox","RoomMailbox","EquipmentMailbox")
    }

    # Apply default quotas
    foreach ($mb in $mailboxes) {
        Set-MailboxQuotaIfNeeded $mb.PrimarySmtpAddress "Default" `
            $DefaultQuotas.Warn $DefaultQuotas.Send $DefaultQuotas.SendReceive
    }


    # ========================================================================================
    # PART 2 - TIER 1 USERS
    # ========================================================================================
    $members = Get-DistributionGroupMember $Tier1GroupName | Select-Object -Expand PrimarySmtpAddress
    foreach ($m in $members) {
        Set-MailboxQuotaIfNeeded $m "Tier1" `
            $Tier1Quotas.Warn $Tier1Quotas.Send $Tier1Quotas.SendReceive
    }


    # ========================================================================================
    # PART 3 - TIER 2 USERS
    # ========================================================================================
    $members = Get-DistributionGroupMember $Tier2GroupName | Select-Object -Expand PrimarySmtpAddress
    foreach ($m in $members) {
        Set-MailboxQuotaIfNeeded $m "Tier2" `
            $Tier2Quotas.Warn $Tier2Quotas.Send $Tier2Quotas.SendReceive
    }


    # ========================================================================================
    # PART 4 - SHARED MAILBOXES
    # ========================================================================================
    $shared = Get-Mailbox -RecipientTypeDetails SharedMailbox
    foreach ($mb in $shared) {
        Set-MailboxQuotaIfNeeded $mb.PrimarySmtpAddress "Shared" `
            $SharedQuotas.Warn $SharedQuotas.Send $SharedQuotas.SendReceive
    }


    # ========================================================================================
    # REPORTING
    # ========================================================================================

    # Always export CSV (audit trail)
    $Changes | Export-Csv $CsvPath -NoTypeInformation

    # =============================
    # SUMMARY CALCULATIONS
    # =============================

    $TotalChanges = $Changes.Count
    $TotalErrors  = $Errors.Count

    $DefaultChanges = ($Changes | Where-Object { $_.Category -eq "Default" }).Count
    $Tier1Changes   = ($Changes | Where-Object { $_.Category -eq "Tier1"   }).Count
    $Tier2Changes   = ($Changes | Where-Object { $_.Category -eq "Tier2"   }).Count
    $SharedChanges  = ($Changes | Where-Object { $_.Category -eq "Shared"  }).Count

    # =============================
    # BUILD REPORT BODY
    # =============================

    $body = "<h2>Mailbox Quota Report</h2>"

    # ===== SUMMARY SECTION =====
    $body += "<b>Run Time:</b> $RunTime<br><br>"

    $body += "<h3>Summary</h3>"
    $body += "Total Changes: <b>$TotalChanges</b><br>"
    $body += "Errors: <b>$TotalErrors</b><br><br>"

    $body += "<b>Breakdown:</b><br>"
    $body += "Default: $DefaultChanges<br>"
    $body += "Tier1: $Tier1Changes<br>"
    $body += "Tier2: $Tier2Changes<br>"
    $body += "Shared: $SharedChanges<br>"
    $body += "CSV report saved to: $CsvPath<br><br>"

    # ===== DETAIL OUTPUT =====

    if ($Changes.Count -eq 0) {
        $body += "No changes were needed.<br>"
    }
    else {
        foreach ($c in $Changes) {
            $body += "$($c.Mailbox) [$($c.Category)] - Warning $($c.OldWarning) -&gt; $($c.NewWarning)<br>"
        }
    }

    # =============================
    # SEND EMAIL
    # =============================

    if ($SendEmailWhenNoChanges -or $Changes.Count -gt 0) {
        Send-MgUserMail -UserId $Sender -BodyParameter @{
            message = @{
                subject = $Subject
                body = @{ contentType = "HTML"; content = $body }
                toRecipients = $Recipients | ForEach-Object {
                    @{ emailAddress = @{ address = $_ } }
                }
            }
        }
    }

}
catch {
    Write-Host "Run failed: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Disconnect-ExchangeOnline -Confirm:$false
    Disconnect-MgGraph
    Stop-Transcript
}
