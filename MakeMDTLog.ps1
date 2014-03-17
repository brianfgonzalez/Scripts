$sTime = Get-Date -Format hh:mm:ss
$sDate = Get-Date -Format MM-dd-yyyy
# Create Global Variables
$oInvocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $oInvocation.MyCommand.Path
$sScriptNameExt = $oInvocation.MyCommand.Name
$sScriptName = $sScriptNameExt.Substring(0, $sScriptNameExt.Length - 4)
$sUpdate = "Copy of Folder was successful"

$sUpdateStringTest = ("<![LOG[" + $sUpdate + "]LOG]!><time=""" + $sTime + """ date=""" + $sDate + """ component=""" + $sScriptName + """ context="""" type=""1"" thread="""" file=""" + $sScriptName + """>")
Write-Host $sUpdateStringTest

Exit

#$sUpdateStringTest = @("<![LOG[" + $sUpdate + "><time=""" + $sTime + """ date=""" + $sDate + """ component=""" + $sScriptName + """ context="""" type=""2"" thread="""" file="Z-CopyContentToSystemDrive">)


# <![LOG[Copy Folder: D:\Deploy\Applications\Copy Content to SystemDrive\Support\* to C:\Users\SUPPORT]LOG]!><time="08:32:05.000+000" date="03-17-2014" component="Z-CopyContentToSystemDrive" context="" type="1" thread="" file="Z-CopyContentToSystemDrive">
