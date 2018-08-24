# Add hosts entries for local QA tests

$hosts = @"
127.0.0.1 yoursite.com
"@

[System.IO.File]::AppendAllText("$($env:windir)\system32\Drivers\etc\hosts", $hosts)
