#****************************************************************************************
#                       MANAGEMENT INFORMATION
#
#       SYSTEM:       ALARM on Win 10 AGM
#       FILENAME:     ALARM-AGM-Update.ps1
#       LANGUAGE:     Windows PowerShell
#       MOD_ID:  
#***************************************************************************************
#                       PURPOSE
#   Description:
#   
#          - Configures ALARM to run on the Windows 10 AGM
#
#***************************************************************************************
#                       TECHNICAL INFORMATION
#    None
#
#**************************************************************************************
#                       CHANGE HISTORY
#
#    REV          DATE             ANALYST
#                                     - DESCRIPTION OF CHANGE
#
#    -	     1/25/2017 10:25 AM        Adam Austin (Haight Bey & Associates for Vaisala)
#                                      - Initial Release 
#
#*************************************************************************************


$dt = get-date -format "yyyy-MM-dd_hhmm"
$logfile = ($MyInvocation.MyCommand.Name).Replace("ps1","$dt.log")
$logfilelocation = "C:\Users\USAF_Admin\Documents"
start-transcript $logfilelocation\$logfile


$hostname = hostname
$scriptPath = split-path -parent $MyInvocation.MyCommand.Path

###################################################
#          Functions for use in script
###################################################
#analyze exit code
function Analyze-ExitCode
{
    param ($exitcode)


    If (($exitcode -eq 0) -or ($exitcode -eq 3010)) {Write-Host "Install Successful`r" -ForegroundColor green}
    Else {Write-Host "Install Failed or requires reboot--check upon reboot`r" -ForegroundColor red}


}



###################################################
#             Install JRE 8u112 
###################################################
# Do silent install of JRE
Write-Host "Now installing Java JRE 8u112 `r`r"
$javainstallfile = $scriptPath + "\Files\java\jre-8u112-windows-i586.exe"
& $javainstallfile /s INSTALL_SILENT=Enable AUTO_UPDATE=Disable WEB_ANALYTICS=Disable| Out-Null
. Analyze-ExitCode $LastExitCode



###################################################
#            Copy AGM config files into place 
###################################################
Write-Host "Now copying over AGM specific config files `r`r" 
copy -force "$scriptPath\Files\config\patch\*.class" "C:\Program Files (x86)\ALARM\ClassFiles\com\ccg\security"
copy -force "$scriptPath\Files\config\license\*.class" "C:\Program Files (x86)\ALARM\ClassFiles\com\glatmos\ipd\license"
copy -force "$scriptPath\Files\config\license\License" "C:\Program Files (x86)\ALARM"
copy -force "$scriptPath\Files\config\batch\startAlarmServer.bat" "C:\Program Files (x86)\ALARM"
copy -force "C:\Program Files (x86)\ALARM\jre\Lib\Comm.jar" "C:\Program Files (x86)\Java\jre1.8.0_112\lib"
copy -force "C:\Program Files (x86)\ALARM\jre\Lib\javax.comm.properties" "C:\Program Files (x86)\Java\jre1.8.0_112\lib"
copy -force "C:\Program Files (x86)\ALARM\jre\Bin\Win32com.dll" "C:\Program Files (x86)\Java\jre1.8.0_112\bin"


stop-transcript
<#Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#>