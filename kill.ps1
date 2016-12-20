<#
Last Update 15/06/2016
#>

[string] $tmp = Get-Date
$ScriptFile = $MyInvocation.MyCommand.Path
$baseDir = Split-Path $ScriptFile -Parent
$tmp -match "(?<m>.*)/(?<d>.*)/(?<y>.*) (?<t>.*)">$null
$Time = $matches['d']+"/"+$matches['m']+"/"+$matches['y'] +" - " +$matches['t']

shutdown -a
if ($?)
{
    Add-Content "$baseDir\log.txt" "$Time  - System Shutdown Aborted."
    Exit 0 

}

else
{
    Add-Content "$baseDir\log.txt" "$Time  - No shutdown action in progress..."
    Exit 0 
}