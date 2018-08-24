# Stop at first error
$ErrorActionPreference = "Stop"

# Disable annoying Notepad++ update notification
cmd /c ren "c:\Program Files\Notepad++\updater" "updater_disable"

# Fix Chromedriver error
reg add HKLM\SOFTWARE\Policies\Google\Chrome /v MachineLevelUserCloudPolicyEnrollmentToken /t REG_SZ

# Copy NUnit
# rm "C:\agent_tools\NUnit.org\"  -r -fo
# cp -R "C:\ProgramData\chocolatey\lib\nunit-console-runner\tools\*" "C:\agent_tools\NUnit.org\nunit-console"

# Copy NUnit extensions to agent tools folder
# cp -R "C:\ProgramData\chocolatey\lib\nunit-extension*" "C:\agent_tools\"

# Fix Octopus
# rm "C:\agent_tools\OctopusTools.4.21.0"  -r -fo
# mkdir -p C:\agent_tools\OctopusTools.4.21.0
# cp -R "C:\ProgramData\chocolatey\lib\OctopusTools\tools\*" "C:\agent_tools\OctopusTools.4.21.0"

# Initialise browser profiles to speed up their start up afterwards
# Start-Process "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" -ArgumentList '--start-maximized'
Start-Process "C:\Program Files\Mozilla Firefox\firefox.exe" -ArgumentList '--start-maximized'

# Cygwin etc
choco install awscli jq python2 cygwin cyg-get /y

# Cygwin modules
cyg-get openssh python2 curl wget

# Cygwin's awscli
# curl -O https://bootstrap.pypa.io/get-pip.py
# python get-pip.py
# pip install awscli

# Close browsers
# Stop-Process -Name "Chrome" -Force
Stop-Process -Name "Firefox" -Force

# Disable Windows Error Reporting (annoying 'this app has crashed' window)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\Windows Error Reporting" -Name DontShowUI -Value 1

# Fix Site 24x7 / AppDynamics agent error (Jira DO-127)
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\.NETFramework" -Name LoaderOptimization -Value 1
