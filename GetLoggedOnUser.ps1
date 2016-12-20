
<#
Last update 15/06/2016 By Ori

 Bug Fix:
 Change the way we are chacking if there any users log on to the server.
#>

function Get_LoggedUsers
{
    param(
        [CmdletBinding()] 
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName = 'localhost'
    )
    begin {
        $ErrorActionPreference = 'Stop'
    }

    process {
        foreach ($Computer in $ComputerName) {
            try {
                quser /server:$Computer 2>&1 | Select-Object -Skip 1 | ForEach-Object {
                    $CurrentLine = $_.Trim() -Replace '\s+',' ' -Split '\s'
                    $HashProps = @{
                        UserName = $CurrentLine[0]
                        ComputerName = $Computer
                    }

                    # If session is disconnected different fields will be selected
					    if ($CurrentLine[2] -eq 'Disc') {
							    $HashProps.SessionName = $null
							    $HashProps.Id =""
							    $HashProps.State = $CurrentLine[2]
							    $HashProps.IdleTime =""
							    $HashProps.LogonTime =""
							    $HashProps.LogonTime =""
					    } else {
							    $HashProps.SessionName = ""
							    $HashProps.Id = ""
							    $HashProps.State = ""
							    $HashProps.IdleTime = $CurrentLine[4]
							    $HashProps.LogonTime = ""
					    }


					    New-Object -TypeName PSCustomObject -Property $HashProps |
					    Select-Object -Property UserName,ComputerName,SessionName,Id,State,IdleTime,LogonTime,Error
				    }
			    } catch {
				    New-Object -TypeName PSCustomObject -Property @{
					    ComputerName = $Computer
					    Error = $_.Exception.Message
				    } | Select-Object -Property UserName,ComputerName,SessionName,Id,State,IdleTime,LogonTime,Error
			    }
        }
    }
}
$ScriptFile = $MyInvocation.MyCommand.Path
$baseDir = Split-Path $ScriptFile -Parent
$Sleep = 7200
$Stime = $Sleep / 60
$output = Get_LoggedUsers
[string] $tmp = Get-Date
$tmp -match "(?<m>.*)/(?<d>.*)/(?<y>.*) (?<t>.*)">$null
$Time = $matches['d']+"/"+$matches['m']+"/"+$matches['y'] +" - " +$matches['t']

if($output -match "@{UserName=(?<res>.*); ComputerName=localhost; SessionName=; Id=; State=; IdleTime=(?<resu>.*); LogonTime=; Error=}")
{
    Add-Content "$baseDir\log.txt" "$Time  - There are still active users on the server."
    Exit 0
}

else
{	Add-Content "$baseDir\log.txt" "$Time - Will Shut Down in $Stime Minutes"
	shutdown -s -t $Sleep
}