# Create IIS Manager desktop shortcut
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\IIS.lnk")
$Shortcut.TargetPath = "%systemroot%\system32\inetsrv\iis.msc"
$Shortcut.Save()

# Create Register in Octopus link
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Octopus_Start.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-File C:\Users\Administrator\register_octopus.ps1"
$Shortcut.Save()

# Create Stop Octopus link
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Octopus_Stop.lnk")
$Shortcut.TargetPath = "C:\Windows\System32\cmd.exe"
$Shortcut.Arguments = "/c net stop `"OctopusDeploy Tentacle`""
$Shortcut.Save()

# Create Powershell link
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Powershell.lnk")
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Save()

# Create cmd link
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\cmd.lnk")
$Shortcut.TargetPath = "cmd.exe"
$Shortcut.Save()

# Create Shutdown link
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Shutdown.lnk")
$Shortcut.TargetPath = "shutdown"
$Shortcut.Arguments = "/s /t 0"
$Shortcut.Save()

# Run IIS Manager on logon
Invoke-Item $env:WinDir\system32\inetsrv\iis.msc
