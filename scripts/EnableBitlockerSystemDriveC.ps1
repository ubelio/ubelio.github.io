#This script will check for the status of Bitlocker and Install Bitlocker in the System drive for computers at DMI
#This script will also check for the TPM version and use the TPM module for Bitlocker only if the TPM version is 2.0 or higher

#Check TPM version 
$TPMver = Get-CIMInstance -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm | Select SpecVersion

#If the TPM version is 2.0 use the TPM for Bitlocker, else discard the TPM
if ($TPMver -match '2.0')
{

#Check Status of System Drive C
$DRIVE = Get-BitLockerVolume -MountPoint 'c:'

#IF the status is Decrypted, Add Bitlocker password protector as random 48 digit Key. GPO will back up the key to AD
#Enable bitlocker to System Drive with Aes256 Encryption and using the TMP for highest simplicity and security
if ($DRIVE.VolumeStatus -eq 'FullyDecrypted') {
    Add-BitLockerKeyProtector -MountPoint 'c:' -RecoveryPasswordProtector
    Enable-Bitlocker -MountPoint 'c:' -TpmProtector
}
}
else
{

#Check Status of System Drive C
$DRIVE = Get-BitLockerVolume -MountPoint 'c:'

#IF the status is Decrypted, Add Bitlocker password protector as random 48 digit Key. GPO will back up the key to AD
#Enable bitlocker to System Drive with Aes256 Encryption 
if ($DRIVE.VolumeStatus -eq 'FullyDecrypted') {
    Add-BitLockerKeyProtector -MountPoint 'c:' -RecoveryPasswordProtector
    Enable-Bitlocker -MountPoint 'c:' -RecoveryPasswordProtector
}
}

Exit

#end
