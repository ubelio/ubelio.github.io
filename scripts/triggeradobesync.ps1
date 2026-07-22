# =============================
# CONFIGURATION SECTION
# =============================
# These values allow the script to authenticate securely without user prompts.
$AppId      = ""   # Azure AD App Registration Client ID
$TenantId   = ""   # Azure AD Tenant ID
$Thumbprint = "" # Certificate thumbprint for app-only auth
$Org        = ""    # Microsoft 365 organization domain

Connect-MgGraph -AppId $AppId -TenantID $TenantId -CertificateThumbprint $Thumbprint


#Get the Service Principal for the Adobe enterprise app (adjust the name if yours differs)
$sp = Get-MgServicePrincipal -Filter "displayName eq 'Adobe Identity Management (OIDC)'"


#List the synchronization job(s) for that Service Principal
$jobs = Get-MgServicePrincipalSynchronizationJob -ServicePrincipalId $sp.Id
$jobs | Select-Object Id, TemplateId, @{n='StatusCode';e={$_.Status.Code}}, @{n='LastSuccess';e={$_.Status.LastSuccessfulExecution.EndDateTime}}


#Capture the job Id (take the first job)
$jobId = ($jobs | Select-Object -First 1 -ExpandProperty Id)


#Start the synchronization job
Start-MgServicePrincipalSynchronizationJob -ServicePrincipalId $sp.Id -SynchronizationJobId $jobId
