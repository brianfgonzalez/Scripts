<#
    IMPORT ZTIUtility.ps1
#>
$oInvocation = (Get-Variable MyInvocation).Value
Set-Location Split-Path $oInvocation.MyCommand.Path
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