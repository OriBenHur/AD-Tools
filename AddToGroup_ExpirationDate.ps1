Clear-Host
[string]$err2 = "Cannot validate argument on parameter 'Identity'."
$ScriptName = ".\"+$MyInvocation.MyCommand.Name 
$User = $Group = $Date = $Time = $null

function Syntex
{
	[string] $tmp = Get-Date
	$tmp -match "(?<m>.*)/(?<d>.*)/(?<y>.*) (?<t>.*)">$null
	$_Time = $matches['d']+"/"+$matches['m']+"/"+$matches['y']
	write-host "`nFor this help menue type"$ScriptName" {/? | -h | --help}`n"
	write-host "`nUsage:`n"$ScriptName "{-g GroupName -u Username} [-d AccountExpirationDate] [-t AccountExpirationTime]`n"
	write-host "Exemples:"
	write-host "	"$ScriptName " -g Mygroup -u MyUser"
	write-host "	 Output: MyUser Was added to MyGroup`n" -ForegroundColor Green
	write-host "	"$ScriptName "-g Mygroup -u MyUser -t 10:00"
	write-host "	 Output: MyUser - Expiration was set to" $_Time "at 10:00`n" -ForegroundColor Green
	write-host "	"$ScriptName "-g Mygroup -u MyUser -d 30/04/2016 -t 10:00"
	write-host "	 Output: MyUser - Expiration was set to 30/04/2016 at 10:00`n" -ForegroundColor Green
	write-host "	"$ScriptName "-g Mygroup -u MyUser -d 30/04/2016"
	write-host "	 Output: MyUser - Expiration was set to 30/04/2016 at 00:00`n" -ForegroundColor Green
	write-host "	"$ScriptName "-u MyUser -t 10:00"
	write-host "	 Output: MyUser - Expiration was set to" $_Time "at 10:00`n" -ForegroundColor Green
	write-host "	"$ScriptName "-u MyUser -u 30/04/2016 -t 10:00"
	write-host "	 Output: MyUser - Expiration was set to 30/04/2016 at 10:00`n" -ForegroundColor Green
	write-host "	"$ScriptName "-u MyUser -u 30/04/2016"
	write-host "	 Output: MyUser - Expiration was set to 30/04/2016 at 00:00`n" -ForegroundColor Green
}
function Test-IsISE {
# try...catch accounts for:
# Set-StrictMode -Version latest
    try {    
        return $psISE -ne $null;
    }
    catch {
        return $false;
    }
}
for ($i = 0; $i -lt $args.Length; $i++)
{
    switch ($args[$i].ToLower())
    {
        "-g"
        {
            $Group = $args[++$i]
            break;
        }

        "-u"
        {
            $User = $args[++$i]
            break;
        }

        "-d"
        {
            $Date = $args[++$i];
            break;
        }

        "-t"
        {
            $Time = $args[++$i];
            break;
        }
    }
}


if($args[0] -eq "/?" -or $args[0] -eq "-h" -or $args[0] -eq "--help" -or $args[0] -eq $null)
{
    Syntex
    
}
else
{

     try
    {
		if (-not (Get-Module -Name "activedirectory")) 
		{
			write-host "loading..."
			import-module activedirectory
		}

        if($Date -eq $null -and $Time -eq $null)
        {
                ADD-ADGroupMember $Group $User  
                write-host "$User Was added to $Group`n"
        }


        else
        {
			if($Group -ne $null)
            {
				ADD-ADGroupMember $Group $User
				if($Date -ne $null -or $Time -ne $null)
				{
				
					Set-ADAccountExpiration -Identity $User "$Date $Time"
					write-host "$User - Expiration was set to $Date at $Time`n"

				}
			}
			else
			{
				if($Date -ne $null -or $Time -ne $null)
				{
					[string] $tmp = Get-Date
					$tmp -match "(?<m>.*)/(?<d>.*)/(?<y>.*) (?<t>.*)">$null
					$_Time = $matches['d']+"/"+$matches['m']+"/"+$matches['y']
					if(Test-IsISE)
					{
						Set-ADAccountExpiration -Identity $User "$Date $Time"
						if($Date -eq $null ) {write-host "$User - Expiration was set to $_Time at $Time`n"}
						elseif($Time -eq $null ) {write-host "$User - Expiration was set to $Date at 00:00`n"}
						else{write-host "$User - Expiration was set to $Date at $Time`n"}
					}
					else
					{
						$tmp = $Date
						$tmp -match "(?<d>.*)/(?<m>.*)/(?<y>.*)">$null
						$_Date = $matches['m']+"/"+$matches['d']+"/"+$matches['y']
						Set-ADAccountExpiration -Identity $User "$_Date $Time"
						if($Date -eq $null ) {write-host "$User - Expiration was set to $_Time at $Time`n"}
						elseif($Time -eq $null ) {write-host "$User - Expiration was set to $Date at 00:00`n"}
						else{write-host "$User - Expiration was set to $Date at $Time`n"}
					}
				}
			}
		}
    }
    catch
    {
        [string]$err = $($_.Exception.Message)
        #$err = (Get-Culture).TextInfo.ToTitleCase($err)

        if($err -eq "The specified account name is already a member of the group")
        {
            if($Date -ne $null -or $Time -ne $null)
            {
                [string] $tmp = Get-Date
                $tmp -match "(?<m>.*)/(?<d>.*)/(?<y>.*) (?<t>.*)">$null
                $_Time = $matches['d']+"/"+$matches['m']+"/"+$matches['y']
				if(Test-IsISE)
				{
					Set-ADAccountExpiration -Identity $User "$Date $Time"
					if($Date -eq $null ) {write-host "$User - Expiration was set to $_Time at $Time`n"}
					elseif($Time -eq $null ) {write-host "$User - Expiration was set to $Date at 00:00`n"}
					else{write-host "$User - Expiration was set to $Date at $Time`n"}
				}
				else
				{
					$tmp2 = $Date
					$tmp2 -match "(?<d>.*)/(?<m>.*)/(?<y>.*)">$null
					$_Date = $matches['m']+"/"+$matches['d']+"/"+$matches['y']
					Set-ADAccountExpiration -Identity $User "$_Date $Time"
					if($Date -eq $null ) {write-host "$User - Expiration was set to $_Time at $Time`n"}
					elseif($Time -eq $null ) {write-host "$User - Expiration was set to $Date at 00:00`n"}
					else{write-host "$User - Expiration was set to $Date at $Time`n"}
				}
            }
            else
            {
                write-host "$err" -ForegroundColor Red -BackgroundColor Gray "`n"   
				exit 808040
            }
        }
        elseif("$err" -Match $err2)
        {
            write-host "`nWrong Syntax!" -ForegroundColor Red 
            Syntex
			exit 808040
        }
        else
        {
            write-host "Group: " $Group
            write-host "User: " $User
            write-host "Time: " $Time
            write-host "Date: " $Date
            write-host "$err" -ForegroundColor Red -BackgroundColor Gray "`n"
			exit 808040
        }
    }
}
