$User = (Read-Host -Prompt "admsubr")
$OldPassword = (Read-Host -asSecureString "Enter the current password")
$NewPassword = (Read-Host -asSecureString "Enter the new password")
Set-AdAccountPassword -Identity $User -OldPassword $OldPassword -NewPassword $NewPassword