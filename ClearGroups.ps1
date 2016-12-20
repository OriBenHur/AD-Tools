$ScriptName = ".\"+$MyInvocation.MyCommand.Name 
#$gras[$i] = $args[$i]
if($args -eq "/?" -or $args -eq "-h" -or $args -eq "--help")
{
	cls
    write-host "`nUsage:`n"$ScriptName "{group_1 group_2 group_3 ... group_n} | {-g GroupName -u Username}`n"
	 write-host "Usage Options:"
	write-host ""$ScriptName "group_1 group_2 group_3 ... group_n"
	write-host ""$ScriptName  "-g group 1 -u user1`n"
    write-host "Exemples:"
    write-host "	"$ScriptName "Mygroup"
    write-host "	 Output:`n	 All users in Mygroup were removed`n`n" -ForegroundColor Green
    write-host "	"$ScriptName "Mygroup Mygroup2"
    write-host "	 Output:`n	 All users in Mygroup were removed" -ForegroundColor Green
    write-host "	 All users in Mygroup2 were removed`n`n" -ForegroundColor Green
    write-host "	"$ScriptName "Mygroup Mygroup2 Mygroup3"
    write-host "	 Output:`n	 All users in Mygroup were removed" -ForegroundColor Green
    write-host "	 All users in Mygroup2 were removed" -ForegroundColor Green
    write-host "	 All users in Mygroup3 were removed`n`n" -ForegroundColor Green
	write-host "	"$ScriptName "-g Mygroup -u Myuser"
    write-host "	 Output:`n	 Myuser Was removed successfully from Mygroup`n`n" -ForegroundColor Green
	write-host "	"$ScriptName "-u Myuser2 -g Mygroup2"
    write-host "	 Output:`n	 Myuser2 Was removed successfully from Mygroup2`n`n" -ForegroundColor Green


}
else
{
    if (-not (Get-Module -Name "activedirectory")) 
	{
		write-host "loading..."
		import-module activedirectory
	}


	if($args[0] -eq "-g" -or $args[0] -eq "-u")
	{
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
			}
		}
		try
		{
			Remove-ADGroupMember -Identity $Group -member $User -Confirm:$false
			write-host ""
			write-host $User" Was removed successfully from "$Group -ForegroundColor Green"`n"
            exit 0
		}

		catch 
		{
			[string]$err = $($_.Exception.Message)
			[string]$err2 = "The specified account name is not a member of the group"
			if("$err" -Match $err2)
			{
				write-host ""
				write-host $User" is not a member of "$Group -ForegroundColor Red -BackgroundColor Gray "`n"
                exit 1
			}
			
			else
			{
				write-host "$err" -ForegroundColor Red -BackgroundColor Gray "`n"
                $err | Add-Content C:\lo\log.log
                exit 0x22
			}
		}
	}
	else
	{
		foreach ($grp in $args) 
		{
			try
			{
				if(Get-ADGroup $grp  | Where-Object {@(Get-ADGroupMember $_).Length -eq 0}) 
				{ 
					write-host $grp "is already empty`n"
                    exit 3
                    
				}

				else
				{
					Get-ADGroupMember $grp | ForEach-Object {Remove-ADGroupMember $grp $_ -Confirm:$false}
					write-host "All users in" $grp "were removed`n"
                    exit 0

				}
			}

			catch 
			{
                [string]$err = $($_.Exception.Message)
                #write-host "$err" -ForegroundColor Red -BackgroundColor Gray "`n"
				write-host "`n"$grp " - No such group exist" -ForegroundColor Red -BackgroundColor Gray "`n"
                exit 4

			}
		}
	}

}