<#function Test-IsISE {
    try 
    {    
        return $psISE -ne $null;
    }
    catch 
    {
        return $false;
    }
}#>

$Now = Get-Date
$Group = $args[1]
$User = $args[0]
$Time = $args[3]
$Date = $args[2]
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$Dir = $ScriptDir +"\ClearUserFromGroup.ps1"

$UserName = "GroupM"
$PasswordFile = "C:\system_tools\ADGroupsMng\password.txt"
$KeyFile = "C:\system_tools\ADGroupsMng\AES.key"
$key = Get-Content $KeyFile
$MyCredential = New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $UserName, (Get-Content $PasswordFile | ConvertTo-SecureString -Key $key)
<#if(Test-IsISE)
{
 #echo "ISE"
    $tmpDate = $Date +" " +$Time
    $UserDate = $tmpDate -as [DateTime]

}
else
{
 #echo "Not ISE"
    $tmp = $Date
 #  echo "tmp: $tmp"
	$tmp -match "(?<d>.*)/(?<m>.*)/(?<y>.*)">$null
  #  echo "tmp: $tmp"
	$_Date = $matches['m']+"/"+$matches['d']+"/"+$matches['y']
    $tmpDate = $_Date +" " +$Time
    #$UserDate = $tmpDate -as [DateTime]
    $UserDate = $Date+" "+$Time
}

#echo "Time: $Time"
#echo "_Date: $_Date"
#echo "Date: $Date"
#echo "tmpDate: $tmpDate"
#echo "UserDate: $UserDate"#>

try
{
	$tmpDate = $Date +" " +$Time
    [DateTime]$UserDate = $tmpDate
}
catch
{
	$tmp = $Date
	$tmp -match "(?<d>.*)/(?<m>.*)/(?<y>.*)">$null
	$_Date = $matches['m']+"/"+$matches['d']+"/"+$matches['y']
	$tmpDate = $_Date +" " +$Time
	try
	{
		[DateTime]$UserDate = $tmpDate
        $Date = $_Date
	}
	
	catch
	{
		write-host "Error: The Given Date was not recognized as a valid Date, Please Try again" -ForegroundColor Red 
		Exit 808040
	}
	
	
}

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$Dir = $ScriptDir +"\ClearUserFromGroup.ps1"
#echo "Now: $Now"
if($UserDate -lt $Now)
{
    write-host "Error the given time is in the past" -ForegroundColor Red 
}

else
{
    $Day = Get-Date $UserDate -Format dd
    $Month = Get-Date $UserDate -Format MMMMM
    $Year = Get-Date $UserDate -Format yyyy
    $UserTime = $Month+" "+$Day+", "+ $Year+" "+$Time
    Powershell.exe -executionpolicy remotesigned -File C:\system_tools\ADGroupsMng\AddToGroup_ExpirationDate.ps1 -g $Group -u $User
    if ($LASTEXITCODE -ne 808040)
    {
        Write-Output "Group membership expiration time has been set to: $UserTime UTC"
        Write-Output ""
        
        SchTasks /Create /RU $MyCredential.UserName /RP $MyCredential.GetNetworkCredential().Password /SC ONCE /ST $Time /SD $Date /F /TN "Remove $User from $Group" /TR "powershell.exe -windowstyle hidden -executionpolicy remotesigned -File $Dir -g  $Group -u $User" /RL HIGHEST
    }
}