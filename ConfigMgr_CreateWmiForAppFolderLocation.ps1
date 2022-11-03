param
(
    [Parameter(Mandatory = $false)]
    $ApplicationName = '*', 
    [Parameter(Mandatory = $true)]
    $SiteCode
)

$nameSpace = "root\sms\site_$SiteCode"
$matchedApps = Get-CimInstance -Namespace $nameSpace -Query "SELECT ModelName, LocalizedDisplayName FROM SMS_ApplicationLatest WHERE LocalizedDisplayName LIKE '$($ApplicationName -replace '\*', '%')'"
foreach ($app in $matchedApps) {
    $appFolderInfo = Get-CimInstance -Namespace $nameSpace -Query "SELECT ContainerNodeID FROM SMS_ObjectContainerItem WHERE InstanceKey = '$($app.ModelName)'"
    $appFolder = Get-CimInstance -Namespace $nameSpace -Query "SELECT Name, ContainerNodeID, ParentContainerNodeID FROM SMS_ObjectContainerNode WHERE ContainerNodeID = '$($appFolderInfo.ContainerNodeID)'"
    $appFolderPath = $appFolder.Name
    while ($appFolder.ParentContainerNodeID -ne 0) {
        $appFolder = Get-CimInstance -Namespace $nameSpace -Query "SELECT Name, ContainerNodeID, ParentContainerNodeID FROM SMS_ObjectContainerNode WHERE ContainerNodeID = '$($appFolder.ParentContainerNodeID)'"
        $appFolderPath = [string]::Join('\', @($appFolder.Name, $appFolderPath))
    }

    [PSCustomObject]@{
        ApplicationName = $app.LocalizedDisplayName
        ApplicationFolderPath = [string]::Join('\', $('Applications', $appFolderPath))
        ApplicationModelName = $app.ModelName
        ApplicationContainerID = $appFolderInfo.ContainerNodeID
    } 
}