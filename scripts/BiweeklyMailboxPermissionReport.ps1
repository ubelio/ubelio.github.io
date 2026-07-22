
############################################################
# Script Name: BiweeklyMailboxPermissionReport.ps1
# Purpose:
#   - Pull mailbox permission changes from Microsoft 365 audit logs
#   - Export them to a CSV report
#   - Add two extra columns that resolve GUIDs or raw IDs to actual email addresses
#   - Email the report to specified recipients
#   - Date range: Last 14 days
#   - File name includes timestamp for uniqueness
#
# Requirements:
#   Exchange Online (app-only, certificate auth):
#     - Exchange.ManageAsApp application permission
#     - A directory role granting audit log search (e.g. Compliance Administrator
#       or a custom role with View-Only Audit Logs) assigned to the app
#   Microsoft Graph (application permissions, admin consent required):
#     - User.Read.All   (resolve GUIDs to user principal names)
#     - Mail.Send       (send the report)
#   Modules: ExchangeOnlineManagement, Microsoft.Graph.Authentication,
#            Microsoft.Graph.Users, Microsoft.Graph.Users.Actions
#
#   The auth certificate must be installed in the certificate store of the
#   account running the script (typically a scheduled task service account).
############################################################

# =============================
# CONFIGURATION SECTION
# =============================
# These values allow the script to authenticate securely without user prompts.
$AppId      = ""   # Entra app registration (client) ID
$TenantId   = ""   # Entra tenant ID
$Thumbprint = ""   # Thumbprint of the auth certificate installed on this machine
$OutputPath = ""   # Folder where reports are written and retained, e.g. \\server\share\MailboxReports
$Org        = ""   # Microsoft 365 organization domain, e.g. contoso.onmicrosoft.com

# Email details for sending the report
$Sender     = ""            # UPN of the sending mailbox (requires Mail.Send)
$Recipients = @("")         # One or more recipient addresses
$Subject    = "Biweekly Mailbox Permission Changes Report" # Email subject line
$Body       = "Attached is the biweekly report covering mailbox permission changes for the last 14 days." # Email body text

# =============================
# DATE RANGE (Last 14 Days)
# =============================
# Calculate start and end dates for the report.
$StartDate = (Get-Date).AddDays(-14) # Start date = 14 days ago
$EndDate   = Get-Date                # End date = now

# =============================
# CONNECT TO EXCHANGE ONLINE
# =============================
# Use app-only authentication with a certificate for secure, non-interactive login.
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -AppId $AppId -CertificateThumbprint $Thumbprint -Organization $Org

# =============================
# CONNECT TO MICROSOFT GRAPH
# =============================
# Graph API is used later to send the email and resolve identities if EXO fails.

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users          # provides Get-MgUser for GUID resolution
Import-Module Microsoft.Graph.Users.Actions  # provides Send-MgUserMail
Connect-MgGraph -ClientId $AppId -TenantId $TenantId -CertificateThumbprint $Thumbprint

# =============================
# ENSURE OUTPUT DIRECTORY EXISTS
# =============================
# If the folder doesn’t exist, create it.
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

# =============================
# DYNAMIC FILE NAME
# =============================
# Include date and time in the file name for uniqueness (important for manual runs).
$OutputCSV = "$OutputPath\MailboxPermissionChanges_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').csv"

# =============================
# HELPER FUNCTIONS FOR ID RESOLUTION
# =============================
# Purpose: Convert GUIDs or raw IDs into actual email addresses using EXO and Graph.
# Cache results to avoid repeated lookups for the same identity.
$ResolveCache = @{}

function Get-ResolvedUPN {
    param([string]$Identity)

    # Check cache first
    if ($ResolveCache.ContainsKey($Identity)) { return $ResolveCache[$Identity] }

    # Handle empty or already email-like values
    if ([string]::IsNullOrWhiteSpace($Identity)) { $ResolveCache[$Identity] = ""; return "" }
    if ($Identity -match '^[^@\s]+@[^@\s]+\.[^@\s]+$') { $ResolveCache[$Identity] = $Identity; return $Identity }

    # Extract GUID if present
    $guid = $null
    if ($Identity -match '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})') {
        $guid = $matches[1]
    }

    # First attempt: Exchange Online recipient lookup.
    # Works for GUIDs and for other identity forms EXO accepts (alias, DN, SMTP).
    try {
        $exo = Get-Recipient -Identity $Identity -ErrorAction Stop

        if ($exo) {
            if ($exo.PrimarySmtpAddress) {
                $ResolveCache[$Identity] = $exo.PrimarySmtpAddress.ToString()
            } elseif ($exo.WindowsLiveID) {
                $ResolveCache[$Identity] = $exo.WindowsLiveID.ToString()
            } else {
                $ResolveCache[$Identity] = $exo.DisplayName
            }
            return $ResolveCache[$Identity]
        }
    } catch {
        # Ignore errors and continue to Graph fallback
    }

    # Second attempt: Microsoft Graph (only if GUID is available)
    if ($guid) {
        try {
            $mgUser = Get-MgUser -UserId $guid -ErrorAction Stop
            if ($mgUser) {
                if ($mgUser.UserPrincipalName) {
                    $ResolveCache[$Identity] = $mgUser.UserPrincipalName
                } elseif ($mgUser.Mail) {
                    $ResolveCache[$Identity] = $mgUser.Mail
                } else {
                    $ResolveCache[$Identity] = $Identity
                }
                return $ResolveCache[$Identity]
            }
        } catch {
            # Ignore Graph errors
        }
    }

    # Fallback: return original value
    $ResolveCache[$Identity] = $Identity
    return $Identity
}

# =============================
# GET AUDIT DATA FROM UNIFIED AUDIT LOG
# =============================
# Pull mailbox permission changes for the last 14 days.
$AuditData = Search-UnifiedAuditLog -StartDate $StartDate -EndDate $EndDate `
    -Operations Add-MailboxPermission, Remove-MailboxPermission, Add-RecipientPermission, Remove-RecipientPermission `
    -ResultSize 5000

# =============================
# BUILD THE REPORT
# =============================
# For each audit entry:
#   - Parse the JSON
#   - Extract Mailbox and TargetUser from Parameters (like the old working script)
#   - Resolve UPNs for the new columns
#   - Include all other details
$ParsedReport = foreach ($entry in $AuditData) {
    # Convert AuditData (JSON string) into a PowerShell object.
    $json = $null
    try { $json = $entry.AuditData | ConvertFrom-Json } catch { $json = $null }

    # If parsing fails, still output a row with basic info.
    if (-not $json) {
        [PSCustomObject]@{
            Date                   = $entry.CreationDate
            Action                 = $entry.Operations
            Mailbox                = $null
            MailboxResolvedUPN     = $null
            TargetUser             = $null
            TargetUserResolvedUPN  = $null
            AccessRights           = $null
            InheritanceType        = $null
            PerformedBy            = $entry.UserIds
            ClientIP               = $null
            ResultStatus           = $null
            OriginatingServer      = $null
            ExternalAccess         = $null
            RequestId              = $null
        }
        continue
    }

    # Extract raw values for Mailbox and TargetUser (this is what worked before).
    $mailboxRaw = ($json.Parameters | Where-Object { $_.Name -eq "Identity" }).Value
    $targetRaw  = ($json.Parameters | Where-Object { $_.Name -eq "User"     }).Value

    # Resolve UPNs for the new columns.
    $mailboxResolvedUPN = Get-ResolvedUPN -Identity $mailboxRaw
    $targetResolvedUPN  = Get-ResolvedUPN -Identity $targetRaw

    # Build the row.
    [PSCustomObject]@{
        Date                   = $entry.CreationDate
        Action                 = $entry.Operations
        Mailbox                = $mailboxRaw
        MailboxResolvedUPN     = $mailboxResolvedUPN
        TargetUser             = $targetRaw
        TargetUserResolvedUPN  = $targetResolvedUPN
        AccessRights           = ($json.Parameters | Where-Object { $_.Name -eq "AccessRights"     }).Value
        InheritanceType        = ($json.Parameters | Where-Object { $_.Name -eq "InheritanceType"  }).Value
        PerformedBy            = $entry.UserIds
        ClientIP               = $json.ClientIP
        ResultStatus           = $json.ResultStatus
        OriginatingServer      = $json.OriginatingServer
        ExternalAccess         = $json.ExternalAccess
        RequestId              = $json.RequestId
    }
}

# =============================
# EXPORT TO CSV
# =============================
# If we have data, export it. If not, write "No changes" message.
if ($ParsedReport -and $ParsedReport.Count -gt 0) {
    $ParsedReport | Export-Csv -Path $OutputCSV -NoTypeInformation
} else {
    "No mailbox permission changes detected during this period." | Out-File -FilePath $OutputCSV
}

# =============================
# DISCONNECT EXCHANGE ONLINE
# =============================
Disconnect-ExchangeOnline -Confirm:$false

# =============================
# SEND EMAIL WITH ATTACHMENT
# =============================
# Read the CSV file and convert it to Base64 for Graph API.
$FileBytes   = [System.IO.File]::ReadAllBytes($OutputCSV)
$Base64File  = [System.Convert]::ToBase64String($FileBytes)

# Build the email message object.
$EmailMessage = @{
    Message = @{
        Subject     = $Subject
        Body        = @{ ContentType = "Text"; Content = $Body }
        ToRecipients= @()
        Attachments = @(
            @{
                "@odata.type" = "#microsoft.graph.fileAttachment"
                Name          = [System.IO.Path]::GetFileName($OutputCSV)
                ContentBytes  = $Base64File
            }
        )
    }
    SaveToSentItems = $true
}

# Add recipients to the email.
foreach ($Recipient in $Recipients) {
    $EmailMessage.Message.ToRecipients += @{ EmailAddress = @{ Address = $Recipient } }
}

# Send the email using Microsoft Graph.
Send-MgUserMail -UserId $Sender -BodyParameter $EmailMessage
