# Taken from here:
# https://blogs.technet.microsoft.com/heyscriptingguy/2014/05/14/use-powershell-to-create-job-that-runs-at-startup/

# Add userdata execution task
$trigger = New-JobTrigger -AtStartup
Register-ScheduledJob -Trigger $trigger -FilePath C:\Users\Administrator\execute_userdata.ps1 -Name RunUserData

# Add userdata execution task
$trigger = New-JobTrigger -AtLogon
Register-ScheduledJob -Trigger $trigger -FilePath C:\Users\Administrator\execute_userdata.ps1 -Name RunUserData-atLogon

# Add Octopus
$trigger = New-JobTrigger -AtLogon
Register-ScheduledJob -Trigger $trigger -FilePath C:\Users\Administrator\register_octopus.ps1 -Name RegisterInOctopus
write-output "Octopus has been added to startup"

# Add Notepad++ set as default
$trigger = New-JobTrigger -AtLogon
Register-ScheduledJob -Trigger $trigger -FilePath C:\Users\Administrator\set_notepad_default.ps1 -Name NotepadPlusPlusSetDefault
write-output "Notepad Plus Plus has been added to startup"

# Add logon items
$trigger = New-JobTrigger -AtLogon -RandomDelay 00:00:15
Register-ScheduledJob -Trigger $trigger -FilePath C:\Users\Administrator\logon_items.ps1 -Name AddLogonItems
write-output "Logon items have been added to startup"

# Add TeamCity Agent to startup
$teamcity_agent = "C:\BuildAgent\bin\agent.bat start"
#[System.IO.File]::WriteAllLines("C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\teamcity_agent.bat", $teamcity_agent)
[System.IO.File]::WriteAllLines("C:\Users\$Env:AdminUser\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\teamcity_agent.bat", $teamcity_agent)

$teamcity_agent = "start-process `"cmd.exe`" `"/c C:\BuildAgent\bin\agent.bat start`""
# it is expected that TeamCity agent is installed by the time this is run
# mkdir C:\BuildAgent\bin\
#$teamcity_agent | Out-File C:\BuildAgent\bin\agent.ps1
#$trigger = New-JobTrigger -AtLogon -RandomDelay 00:00:15
#Register-ScheduledJob -Trigger $trigger -FilePath C:\BuildAgent\bin\agent.ps1 -Name TeamCityAgent1
#write-output "TeamCity agent has been added to startup"
