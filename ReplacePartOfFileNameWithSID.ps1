$sPictureFolderPath = "C:\AiO\Applications\Assign Wallpaper and User Tile\Support"
$sBrianDownSID = (gwmi -Query "SELECT SID From Win32_UserAccount WHERE Name LIKE ""Brian%""").SID
Get-ChildItem $sPictureFolderPath -Filter "*.jpg" | `
    fl *