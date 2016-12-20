import-module activedirectory
Clear-Host
$groups =  $args[0]
$ScriptName = $MyInvocation.MyCommand.Name 
try{
    $results = Get-ADGroupMember -Identity $args[0] | Get-ADUser -Properties displayname, AccountExpirationDate
    ForEach ($r in $results){
         New-Object PSObject -Property @{
                GroupName = $groups
                Username = $r.name
                DisplayName = $r.displayname
                AccountExpirationDate = $r.AccountExpirationDate
         } 
     }
 }
 catch
 {
    if($($_.Exception.Message) -Match  "Cannot find an object with identity:*")
    
    {
        write-host "$($_.Exception.Message)" -ForegroundColor Red -BackgroundColor Gray "`n" 
    }
    else
    {
        "Command line Syntax:`n.\" +$ScriptName+" GroupName`n"  
    }
 }