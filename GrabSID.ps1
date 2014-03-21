$sLockedDownSID = (gwmi -Query "SELECT SID From Win32_UserAccount WHERE Name LIKE ""Locked%""").SID
$sSupportSID = (gwmi -Query "SELECT SID From Win32_UserAccount WHERE Name LIKE ""Locked%""").SID
Write-Host $sLockedDownSID