[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
$sScriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Function Get-FileName($Filter)
{
    $oOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $oOpenFileDialog.initialDirectory = $sScriptDir
    $oOpenFileDialog.filter = $Filter
    $oOpenFileDialog.ShowDialog() | Out-Null
    $oOpenFileDialog.Title = "Find Magick.exe"
    $oOpenFileDialog.filename
}
Function Get-Folder()
{
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.rootfolder = "MyComputer"
    $foldername.ShowDialog() | Out-Null
    $foldername.SelectedPath
}
[System.Windows.MessageBox]::Show('Find Magick.exe from extracted ImageMagick portable package.','Magick.exe prompt')
$sMagickPath = Get-FileName -InitialDir $sScriptDir -Filter "magick.exe| magick.exe"
[System.Windows.MessageBox]::Show('Select the Wallpaper.','Wallpaper')
$sWallpaperPath = Get-FileName -Filter "JPG (*.jpg)| *.jpg|BMP (*.bmp)| *.bmp"
[System.Windows.MessageBox]::Show('Select the output folder.','Output Folder')
$sOutputPath = Get-Folder
New-Item "$sOutputPath\Web\4K\Wallpaper\Windows" -ItemType Directory -Force
New-Item "$sOutputPath\Web\Wallpaper\Windows" -ItemType Directory -Force
Start-Process $sMagickPath -ArgumentList ('"{0}" -resize 768x1024 "{1}\Web\4K\Wallpaper\Windows\img0_768x1024.jpg"' -f $sWallpaperPath,"$sOutputPath") -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1024x768 "{1}\Web\4K\Wallpaper\Windows\img0_1024x768.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1200x1920 "{1}\Web\4K\Wallpaper\Windows\img0_1200x1920.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1366x768 "{1}\Web\4K\Wallpaper\Windows\img0_1366x768.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1600x2560 "{1}\Web\4K\Wallpaper\Windows\img0_1600x2560.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 2160x3840 "{1}\Web\4K\Wallpaper\Windows\img0_2160x3840.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 2560x1600 "{1}\Web\4K\Wallpaper\Windows\img0_2560x1600.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 3840x2160 "{1}\Web\4K\Wallpaper\Windows\img0_3840x2160.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1980x1200 "{1}\Web\Wallpaper\Windows\img0.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1920x1080 "{1}\Background.bmp"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1920x1080 "{1}\Lockscreen.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
Start-Process -FilePath $sMagickPath -ArgumentList ('"{0}" -resize 1920x1080 "{1}\Wallpaper.jpg"' -f $sWallpaperPath,$sOutputPath) -Wait -WindowStyle Hidden
