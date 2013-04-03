#=================Variables========================
#Grab Current Directory
$oInvocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $oInvocation.MyCommand.Path
$sLogLocation = "C:\Windows\Temp\SQLInstallation.log"
If (Test-Path $sLogLocation) { Remove-Item $sLogLocation -Force }

#=================Functions========================
Function WaitForFile($sFileName)
{
	#Loop Script with included sleep and file check
	For($i=1; $i -le 45; $i++)
	{
		If (Test-Path $sFileName){break}
		Start-Sleep -Seconds 60 #Checks for existance of file every minute.
	}
}

Function WriteToLog($sMessage)
{ 
    $sDate = Get-Date -Format "MM/dd/yyyy"
    $sTime = Get-Date -Format "hh:mm:ss"
    $tMessage = "$sDate $sTime : $sMessage"
    $tMessage | Out-File -FilePath $sLogLocation -Append
}


#=================Main Routine========================
WriteToLog "Install SQL 2008 R2 script has begun"
If (!(Test-Path "C:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\MSDBLog.ldf"))
{
	#Copy Install Files to C:\Windows\Temp
    If (!(Test-Path "C:\Windows\Temp\SQL08R2\x64\setup\sql_common_core_msi\pfiles32\sqlservr\100\com\kdz5mbsd.dll"))
    {
    WriteToLog "Copy of SQL install files is nessesary and is beginning."
    Copy-Item "$sCurrentDirectory\*" "C:\Windows\Temp\SQL08R2\" -Recurse -Force
    WriteToLog "Copy of SQL install files is complete."
    }
    #Start Installation
    WriteToLog "SQL Installation is starting..."
    Start-Process -FilePath "C:\Windows\Temp\SQL08R2\setup.exe" -ArgumentList "/Q /IACCEPTSQLSERVERLICENSETERMS /SAPWD=P@ssw0rd /ConfigurationFile=C:\Windows\Temp\SQL08R2\ConfigurationFile.ini" -Wait -WindowStyle Maximized
    WriteToLog "Install returned to Command Shell with the following code: $LASTEXITCODE"
    WaitForFile "C:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\MSDBLog.ldf"
    WriteToLog "Install is complete and verified."
} else {
    WriteToLog "SQL 2008 R2 is already installed."
}