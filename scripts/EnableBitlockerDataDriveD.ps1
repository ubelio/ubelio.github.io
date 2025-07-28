#This script will check for the status of Bitlocker on System Drive and Install Bitlocker in Data Drives D, E, or F if current PC has a data drive available.

#Check Bitlocker Status of additional drives if present
$DRIVEd = Get-BitLockerVolume -MountPoint 'd:'

$DRIVEe = Get-BitLockerVolume -MountPoint 'e:'

$DRIVEf = Get-BitLockerVolume -MountPoint 'f:'

#Check Bitlocker Status of System Drive
$DRIVE = Get-BitLockerVolume -MountPoint 'c:'

#IF the status is Decrypted and C is encrypted, Add Bitlocker password protector as random 48 digit Key. GPO will back up the key to AD
#Enable bitlocker to Data drive with Aes256 Encryption and using AD Password Protection
if ($DRIVEd.volumeStatus -eq 'FullyDecrypted' -and $DRIVE.volumestatus -eq 'FullyEncrypted') 
{
    Add-BitLockerKeyProtector -MountPoint 'd:' -RecoveryPasswordProtector
    Enable-Bitlocker -MountPoint 'd:' -RecoveryPasswordProtector
    Enable-BitLockerAutoUnlock -MountPoint 'd:'
}
if ($DRIVEe.volumeStatus -eq 'FullyDecrypted' -and $DRIVE.volumestatus -eq 'FullyEncrypted') 
{
    Add-BitLockerKeyProtector -MountPoint 'e:' -RecoveryPasswordProtector
    Enable-Bitlocker -MountPoint 'e:' -RecoveryPasswordProtector
    Enable-BitLockerAutoUnlock -MountPoint 'e:'
}
if ($DRIVEf.volumeStatus -eq 'FullyDecrypted' -and $DRIVE.volumestatus -eq 'FullyEncrypted') 
{
    Add-BitLockerKeyProtector -MountPoint 'f:' -RecoveryPasswordProtector
    Enable-Bitlocker -MountPoint 'f:' -RecoveryPasswordProtector
    Enable-BitLockerAutoUnlock -MountPoint 'f:'
}
else
{
exit
}

exit
#end
