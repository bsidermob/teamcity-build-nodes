# Install Choco - the package manager
Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

# Install Teamcity Agent. Make sure this is not at the bottom as the agent performs
# an upgrade after installation so it needs some time before the machine is
# switched off
choco install jre8 /y
choco install TeamCityAgent -params 'serverurl=http://teamcity_url agentName=aws-teamcity-agent' --force --allow-empty-checksums /y

# Etc
choco install vcredist2013 vcredist2015 microsoft-build-tools webdeploy webpi /y
choco install procmon googlechrome firefox notepadplusplus 7zip telnet /y


# Agent tools
choco install nuget.commandline nunit-console-runner octopustools /y
# These paths are hardcoded in TeamCity, hence need to copy files to them
mkdir -p C:\agent_tools\nuget
mkdir -p C:\agent_tools\NUnit.org\nunit-console
cp -R "C:\ProgramData\chocolatey\lib\nunit-console-runner\tools\*" "C:\agent_tools\NUnit.org\nunit-console"
cp "C:\ProgramData\chocolatey\lib\NuGet.CommandLine\tools\NuGet.exe" "C:\agent_tools\nuget\nuget.exe"
mkdir -p "C:\agent_tools\OctopusTools.4.21.0"
cp -R "C:\ProgramData\chocolatey\lib\OctopusTools\tools\*" "C:\agent_tools\OctopusTools.4.21.0"

# SQL Server Management Studio
# choco install sql-server-management-studio /y

# Octopus Tentacle / this is now executed through a separate script
# choco install octopusdeploy.tentacle --install-directory=C:\Octopus /y

# Restart TeamCity Service so it updates itself.
# Without this step first run of TeamCity takes longer.
Restart-Service aws-teamcity-agent

# Install build dependencies
choco install git nodejs.install bower dotnetcoresdk dotnetcore-sdk  /y
# Initialise npm
$env:Path += ";C:\Program Files\nodejs\"
# Install npm addons
npm install gulp --global
npm install gulp-cli --global

# Disable Windows Defender
Remove-WindowsFeature Windows-Defender, Windows-Defender-GUI
#Set-MpPreference -DisableRealtimeMonitoring $true

# Start TeamCity agent in console mode
# start-process 'cmd' "/c C:\BuildAgent\bin\agent.bat start"

# Install NUnit extensions
choco install nunit-extension-nunit-v2-result-writer `
nunit-extension-nunit-v2-driver nunit-extension-vs-project-loader `
nunit-extension-nunit-project-loader nunit-extension-teamcity-event-listener /y

# Copy extensions
cp -R "C:\ProgramData\chocolatey\lib\nunit-extension*" "C:\agent_tools\"

# Disable TeamCity agent service
Set-Service aws-teamcity-agent -StartupType Disabled

Write-Output "Provisioning finished"
