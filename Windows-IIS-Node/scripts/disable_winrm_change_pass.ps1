# Disable WinRM
Set-Service WinRM -StartupType Disabled
winrm set winrm/config/service/auth '@{Basic="false"}'
winrm set winrm/config/service '@{AllowUnencrypted="false"}'

# Create user if it doesn't exist
if(!(Get-LocalUser -Name $Env:AdminUser -ErrorAction SilentlyContinue))
{
New-LocalUser -Name $Env:AdminUser -Description "Build User" -NoPassword -AccountNeverExpires
}

# Change admin pass
Set-LocalUser -Name $Env:AdminUser -Password $("$Env:Password"|ConvertTo-SecureString -AsPlainText -Force) -PasswordNeverExpires $true
write-output "Windows Password has been changed"

# Block WinRM
netsh advfirewall firewall set rule name="WinRM-HTTP" new action=block
Stop-Service WinRM
