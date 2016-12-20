$Out = Get-ChildItem C:\Windows\System32\Tasks | Select-Object Name
foreach($Item in $Out)
{
    if($Item -like '*Remove*')
    {
	        $Output = $Item | select-string "Remove"
	        $Output -match "@{Name=(?<Name>.*)}">$null
            $uName = $matches['Name']

        try
	    {
		    $result = schtasks /query /TN "$uName" /fo LIST /v
		    $Out_Result = $uName

	    }
	
	    catch
	    {

	    }
        try
	    {
		
		    $op = $result| select-string "Last Result:"
		    $op -match "Last Result:                          (?<res>.*)">$null
		    if($matches['res'] -eq "0")
		    {
			    foreach ($Item_Result in $Out_Result)
			    {
				    SchTasks /Delete /TN "$Item_Result" /F
			    }
		    }
	    }
	
	    catch
	    {

	    }

    }
}

