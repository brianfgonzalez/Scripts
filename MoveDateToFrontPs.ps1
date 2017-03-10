<#
Import-Module "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider MDTProvider -Root "D:\8443"

Get-ChildItem -Path 'D:\Backups\OsWims' -Filter '*.wim' -Recurse |
% {
    if($_.Name -imatch "[_|-]([0-9]{1,2})-([0-9]{1,2})-([0-9]{1,4})") { #match #|#-#|#-##|##
        $sDate = Get-Date ('{0}/{1}/{2}' -f $Matches[1],$Matches[2],$Matches[3]) -format yyyyMMdd
        $sNewName = $_.Name  -ireplace "[_|-]([0-9]{2})([0-9]{2})([0-9]{2,4})",""
        $sNewName = ('{0}_{1}' -f $sDate,$sNewName)
        Move-Item  $_.FullName ('D:\Backups\OsWims\{0}' -f $sNewName) -Force -Verbose
        Import-MdtOperatingSystem -Path "DS001:\Operating Systems" -SourceFile ('D:\Backups\OsWims\{0}' -f $sNewName) -DestinationFolder $sNewName -Move -Verbose
    } elseif($_.Name -imatch "[_|-]([0-9]{2})([0-9]{2})([0-9]{2,4})") { #match ######|##
        $sDate = Get-Date ('{0}/{1}/{2}' -f $Matches[1],$Matches[2],$Matches[3]) -format yyyyMMdd
        $sNewName = $_.Name  -ireplace "[_|-]([0-9]{2})([0-9]{2})([0-9]{2,4})",""
        $sNewName = ('{0}_{1}' -f $sDate,$sNewName)
        Move-Item  $_.FullName ('D:\Backups\OsWims\{0}' -f $sNewName) -Force -Verbose
        Import-MdtOperatingSystem -Path "DS001:\Operating Systems" -SourceFile ('D:\Backups\OsWims\{0}' -f $sNewName) -DestinationFolder $sNewName -Move -Verbose
    } else {
        Import-MdtOperatingSystem -Path "DS001:\Operating Systems" -SourceFile $_.FullName -DestinationFolder $_.Name -Move -Verbose
    }
}

Remove-PSDrive -Name "DS001"
#>

$sOsXmlPath = "D:\8443\Control\OperatingSystems.xml"
if(Test-Path -Path $sOsXmlPath) {
    $oXml = [xml](Get-Content -Path $sOsXmlPath)
    $oXml.oss.os |
    % {
       $_.Name = ($_.ImageFile -split '\\')[3]
    }
    $oXml.Save($sOsXmlPath)
}