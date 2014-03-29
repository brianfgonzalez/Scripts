$UpdateSession = New-Object -ComObject Microsoft.Update.Session 
$SearchResult = $null
$UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
$UpdateSearcher.Online = $true
($UpdateSearcher.Search("IsInstalled=1 and Type='Software'")).Updates | `
    %{ Write-Output @($_.Title) } | `
    Sort-Object $_.LastDeploymentChangeTime | `
    Out-File -Append "F:\WendysWinPatches.log"