# This automates Octopus Tentacle installation
# and registers the freshly installed tentacle on the server

# Maintainer
# Mike Chistyakov 

# Credits to:
# https://www.neovolve.com/2015/09/30/simple-octopus-tentacle-installation/
# https://github.com/OctopusDeploy/OctopusDeploy-Api/blob/master/REST/PowerShell/Targets/UpgradeCalamari.ps1

# Original scripts were modified to:
# 1. Include machine name and use internal IP address
# 2. Be able to use multiple roles and environments defined in lists
# 3. Added restart of service after installation
# 4. Define all actions as functions

### Variables

$serverThumbprint = ""
$serverUri = "http://"
$tentacleInstallApiKey = "API-"
# Multiple roles can be specified in this format: $roles = "au-app-server","au-dev-web-server"
$roles = "au-dev-web-server"
$environments = "Development", "Testing"
$installLocation = "C:\Octopus"
$machineNamePrefix = $Env:OctopusMachinePrefix
$machinePolicy = "Disposable Machine Policy"

### Functions

function NewMachineName {
    $webclient = new-object net.webclient
    $instanceid = $webclient.Downloadstring('http://169.254.169.254/latest/meta-data/instance-id')
    $newName = $machineNamePrefix + $instanceid
    return $newName
}

function ObtainOwnerTag {
    $webclient = new-object net.webclient
    $instanceid = $webclient.Downloadstring('http://169.254.169.254/latest/meta-data/instance-id')

    $owner = (aws ec2 describe-tags `
        --filters "Name=resource-id,Values=$instanceid" "Name=key,Values=Owner" `
        --region=ap-southeast-2 `
        --query 'Tags[].Value' --output text
      )
    if ($owner.length -gt 1) {
      return "-" + $owner
    }
}

function Tentacle-Configure([string]$arguments)
{
    Write-Output "Configuring Tentacle with $arguments"

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = "$installLocation\Tentacle.exe"
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.CreateNoWindow = $true;
    $pinfo.UseShellExecute = $false;
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $arguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()

    Write-Host $stdout
    Write-Host $stderr

    if ($p.ExitCode -ne 0) {
        Write-Host "Exit code: " + $p.ExitCode
        throw "Configuration failed"
    }
}

function Get-InternalIP {
     return ( `
        Get-NetIPConfiguration | `
        Where-Object { `
            $_.IPv4DefaultGateway -ne $null `
            -and `
            $_.NetAdapter.Status -ne "Disconnected" `
    } `
  ).IPv4Address.IPAddress
}

function Get-ExternalIP {
    return (Invoke-WebRequest http://myexternalip.com/raw).Content.TrimEnd()
}

function UpgradeCalamari {
    Write-Output "Upgrading Calamari"

    Add-Type -Path "$installLocation\Newtonsoft.Json.dll" # Path to Newtonsoft.Json.dll
    Add-Type -Path "$installLocation\Octopus.Client.dll" # Path to Octopus.Client.dll

    $endpoint = new-object Octopus.Client.OctopusServerEndpoint $serverUri,$tentacleInstallApiKey
    $repository = new-object Octopus.Client.OctopusRepository $endpoint
    $findmachine = $repository.Machines.FindByName("$machineName")
    $machineid = $findmachine.id

    $header = @{ "X-Octopus-ApiKey" = $tentacleInstallApiKey }

    $body = @{
        Name = "UpdateCalamari"
        Description = "Updating calamari on $machineName"
        Arguments = @{
            Timeout= "00:05:00"
            MachineIds = @($machineId) #$MachinID could contain an array of machines too
        }
    } | ConvertTo-Json

    return (Invoke-RestMethod $serverUri/api/tasks -Method Post -Body $body -Headers $header)
}

function modifyServiceRecovery {
    $TentaclesServices = Get-Service | Where-Object {$_.name -like '*Tentacle*'}
    foreach($Tentacle in $TentaclesServices) {
        Write-Host Update serivce options for : $Tentacle.Name
        Write-Host `tDelayed start...
        sc.exe config $Tentacle.Name start= delayed-auto
        Write-Host `tRecovery options...
        sc.exe failure $Tentacle.Name reset=0 actions= restart/0/restart/0/restart/0
        Write-Host 'Complete'
    }
}

function restartService {
    $TentaclesServices = Get-Service | Where-Object {$_.name -like '*Tentacle*'}
    foreach($Tentacle in $TentaclesServices) {
        net stop $Tentacle.Name
        net start $Tentacle.Name
        Write-Host 'Tentacle restart Complete'
    }
}

function installTentacle {
    Write-Output "Beginning Tentacle installation"

    Write-Output "Downloading Octopus Tentacle MSI..."
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
    $downloader = new-object System.Net.WebClient
    $downloader.DownloadFile("https://octopus.com/downloads/latest/OctopusTentacle64", "Tentacle.msi")

    Write-Output "Installing Tentacle"
    $msiExitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "INSTALLLOCATION=$installLocation /i Tentacle.msi /quiet" -Wait -Passthru).ExitCode
    if ($msiExitCode -ne 0) {
        Write-Output "Tentacle MSI installer returned exit code $msiExitCode"
        thrown "Installation aborted"
    }
}


function registerInOctopus {
    Tentacle-Configure "register-with --force --instance `"Tentacle`" --server `"$serverUri`" --apiKey=`"$tentacleInstallApiKey`" --publicHostName `"$ipAddress`" --name `"$machineName`" $roles_list $environment_list --policy `"$machinePolicy`" --comms-style TentaclePassive --console"
    Tentacle-Configure "service --instance `"Tentacle`" --install --start --console"
    Write-Output "Installation of Tentacle complete"
}

function configureTentacle {
    Write-Output "Configuring Tentacle"
    Tentacle-Configure "create-instance --instance `"Tentacle`" --config `"$installLocation\Tentacle.config`" --console"
    Tentacle-Configure "new-certificate --instance `"Tentacle`" --if-blank --console"
    Tentacle-Configure "configure --instance `"Tentacle`" --reset-trust --console"
    Tentacle-Configure "configure --instance `"Tentacle`" --home `"$installLocation`" --app `"$installLocation\Applications`" --port `"10933`" --console"
    Tentacle-Configure "configure --instance `"Tentacle`" --trust `"$serverThumbprint`" --console"
    netsh advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
}

function createRolesList {
    $roles_list = New-Object System.Collections.Generic.List[System.Object]
    foreach ($role in $roles) {
    	$roles_list.Add("--role `"$role`" ")
    	#$roles_list.ToArray()
    	}
    return (-join $roles_list)
}

function createEnvironmentsList {
    $environment_list = New-Object System.Collections.Generic.List[System.Object]
    foreach ($environment in $environments) {
    	$environment_list.Add("--environment `"$environment`" ")
    	#$environment_list.ToArray()
    	}
    return (-join $environment_list)
}


### Actions

# Install Tentacle
# installTentacle

# Load lists into variables
$roles_list = createRolesList
$environment_list = createEnvironmentsList

# Obtain IP address
$ipAddress = Get-InternalIP
Write-Output "Detected IP address as $ipAddress"

# Set new machine name with AWS instance id
$machineName = $((NewMachineName) + (ObtainOwnerTag))

# Configure Tentacle
configureTentacle

# Register in Octopus
registerInOctopus

# Delete MSI installer
#Remove-Item "Tentacle.msi"
#Remove-Item $PSCommandPath

#Enable automatic recovery of Tentacle services
modifyServiceRecovery

# Restart Tentacle Service
restartService

# Upgrade Calamari
UpgradeCalamari
