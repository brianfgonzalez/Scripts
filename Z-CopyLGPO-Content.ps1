<#
    IMPORT ZTIUtility.ps1
#>
$oInvocation = (Get-Variable MyInvocation).Value
Set-Location (Split-Path $oInvocation.MyCommand.Path)
. "..\..\Scripts\ZTIUtility.ps1"
<#
    EXAMPLES OF USING ZTIUtility.ps1
    #Write-Host $oPSUtility.LogPath
    #Write-Host $oPSUtility.ScriptDirectory
    #Write-Host $oPSUtility.ScriptName
    #Write-Host $oPSUtility.ScriptNameWithExtension
    #Write-Host $oPSUtility.SystemDrive
    #$ret = RunWithLogging "cmd.exe" "/C ping 127.0.0.1"
    #CopyWithLogging .\AiO.jpg C:\Windows\Temp
    #LogHelper "Installing 7-Zip"
#>
# Check to see if Locked Down User was created
If (!(Get-WmiObject -Query "SELECT * From Win32_UserAccount WHERE Name LIKE 'Locked%'"))
{
    LogHelper """Locked Down"" user doesn't exist.  Exiting Script." "Error"
    Exit
}
$sLockedDownSID = (gwmi -Query "SELECT * From Win32_UserAccount" | ? {$_.Name -like "Locked*"}).SID
LogHelper ("Found SID for ""Locked Down User"":" + $sLockedDownSID)
CopyWithLogging ".\CapturedLGPOContent" ("C:\Windows\System32\GroupPolicyUsers\" + $sLockedDownSID)
$sReturn = RunWithLogging "cmd.exe" ("/C attrib.exe +R +H ""C:\Windows\System32\GroupPolicyUsers\" + $sLockedDownSID + """ /S /D")
LogHelper ("Copy of LGPO Content complete.  Returned:" + $sReturn)