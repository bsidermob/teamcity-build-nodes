# This is used to run userdata after the machine has been provisioned
# It doesn't run if the machine hasn't been initialized which is time-consuming
# on bootup so this is a small workaround to trigger execution of this data

$userdata = (Invoke-RestMethod 'http://169.254.169.254/latest/user-data').powershell
Invoke-Expression $userdata
