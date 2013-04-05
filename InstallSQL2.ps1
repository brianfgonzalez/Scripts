#=================Variables========================
#Grab Current Directory
$oInvocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $oInvocation.MyCommand.Path
$sLogLocation = "C:\Windows\Temp\SQLInstallation.log"
#If (Test-Path $sLogLocation) { Remove-Item $sLogLocation -Force }
$sRegistryUninstallPathX64 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$sRegistryUninstallPathX86 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$oProcess = New-Object system.Diagnostics.Process
$oProcStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$sCheckPath = ""
#=================Functions========================
Function fWriteToLog($sMessage)
{
    $sDate = Get-Date -Format "MM/dd/yyyy"
    $sTime = Get-Date -Format "hh:mm:ss"
    $tMessage = "$sDate $sTime : $sMessage"
    $tMessage | Write-Host ;$tMessage | Out-File -FilePath $sLogLocation -Append
}
Function fStartProcess($oProcStartInfo, $sCheckPath)
{
    $sCmd = $oProcStartInfo.FileName; $sArg = $oProcStartInfo.Arguments
	fWriteToLog "Executing the following command:`r`n$sCmd $sArg"
	$oProcess.StartInfo = $oProcStartInfo
	$oProcess.Start(); 	$oProcess.WaitForExit()
	fWriteToLog "Install has returned to command shell with the following code: $LASTEXITCODE"
	fWriteToLog "Beginning installation verification process:`r`n$sCheckPath"
	#Loop Script with included sleep and file check
	If ((Test-Path $sCheckPath).length -ne 0)
	{
		For($i=1; $i -le 46; $i++)
		{
            If (Test-Path $sCheckPath) #If Checkfile is found For Loop will break
			    {fWriteToLog "Install is complete and verified.`r`n";break}
            fWriteToLog "Delay $i/45 minutes..."
			Start-Sleep -Seconds 60 #Check for completion of install every minute
			If ($i -eq 45){
            fWriteToLog "Verification of Install did not complete in the alloted 45 minute time period.  Restarting Computer..."
            Restart-Computer}
		}
	} Else {fWriteToLog "No installation verification check passed to fStartProcess..."}
}
#=================Main Routine========================
"============================================================" | Out-File -FilePath $sLogLocation -Append
fWriteToLog "Install SQL, Mobile Forms Script has begun"
$sCheckPath = "C:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLEXPRESS\MSSQL\DATA\MSDBLog.ldf"
If (!(Test-Path $sCheckPath))
{
    If (!(Test-Path "C:\Windows\Temp\SQL08R2\x64\setup\sql_common_core_msi\pfiles32\sqlservr\100\com\kdz5mbsd.dll"))
    {
    fWriteToLog "Copy of SQL install files is nessesary and is beginning."
    Copy-Item "$sCurrentDirectory\*" "C:\Windows\Temp\SQL08R2\" -Recurse -Force | Out-Null
    fWriteToLog "Copy of SQL install files is complete."
    }
    #Start Installation
    fWriteToLog "SQL Installation is starting..."
	$oProcStartInfo.FileName = "C:\Windows\Temp\SQL08R2\setup.exe"
	$oProcStartInfo.Arguments = "/Q /IACCEPTSQLSERVERLICENSETERMS /SAPWD=P@ssw0rd /ConfigurationFile=C:\Windows\Temp\SQL08R2\ConfigurationFile.ini"
	fStartProcess $oProcStartInfo $sCheckPath | Out-Null
} Else {
    fWriteToLog "SQL 2008 R2 Server is already installed.`r`n"
}

fWriteToLog "Install Mobile Forms"
$sCheckPath = "$sRegistryUninstallPathX64\{10BE7BF8-01C3-4FF5-AE39-6DA125C68EE7}"
If (!(Test-Path $sCheckPath))
{
    If (!(Test-Path "C:\Windows\Temp\SQL08R2\RMS_8_4_19.msi"))
    {
    fWriteToLog "Copy of RMS Install files is nessesary and is beginning."
    Copy-Item "$sCurrentDirectory\RMS_8_4_19.msi" "C:\Windows\Temp\SQL08R2\RMS_8_4_19.msi" -Recurse -Force | Out-Null
    fWriteToLog "Copy of RMS Install files is complete."
    }
    #Start Installation
    fWriteToLog "Mobile Forms Installation is starting..."
	$oProcStartInfo.FileName = "msiexec.exe"
	$oProcStartInfo.Arguments = "/i ""C:\Windows\Temp\SQL08R2\RMS_8_4_19.msi"" /qb IS_SQLSERVER_AUTHENTICATION=1 IS_SQLSERVER_USERNAME=sa IS_SQLSERVER_PASSWORD=P@ssw0rd /log C:\Windows\Temp\Mobileforms.txt"
    $oProcStartInfo.LoadUserProfile = "True"
	fStartProcess $oProcStartInfo $sCheckPath | Out-Null
} Else {
    fWriteToLog "Mobile Forms is already installed.`r`n"
}

fWriteToLog "SmartCop"
$sCheckPath = "$sRegistryUninstallPathX64\{D79E6637-C6DE-4946-9083-94D4C46EB929}"
If (!(Test-Path $sCheckPath))
{
    If (!(Test-Path "C:\Windows\Temp\SQL08R2\MCT_8_2_13.msi"))
    {
    fWriteToLog "Copy of Smart Cop is nessesary and is beginning."
    Copy-Item "$sCurrentDirectory\MCT_8_2_13.msi" "C:\Windows\Temp\SQL08R2\MCT_8_2_13.msi" -Recurse -Force | Out-Null
    fWriteToLog "Copy of Smart Cop is complete."
    }
    #Start Installation
    fWriteToLog "Smart Cop Installation is starting..."
	$oProcStartInfo.FileName = "msiexec.exe"
	$oProcStartInfo.Arguments = "/i C:\Windows\Temp\SQL08R2\MCT_8_2_13.msi /qb IS_SQLSERVER_USERNAME=sa IS_SQLSERVER_PASSWORD=P@ssw0rd /log C:\Windows\Temp\SmartCop.txt"
	fStartProcess $oProcStartInfo $sCheckPath | Out-Null
} Else {
    fWriteToLog "Smart Cop is already installed.`r`n"
}
