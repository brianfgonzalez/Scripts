wpeinit

Set OSPART=C

echo Select Disk 0 > X:\diskpart-legacy.txt
echo Clean >> X:\diskpart-legacy.txt
echo Create Partition Primary Size=350 >> X:\diskpart-legacy.txt
echo Active >> X:\diskpart-legacy.txt
echo Format FS=NTFS Label="System Reserved" Quick Override >> X:\diskpart-legacy.txt
echo Assign Letter=S >> X:\diskpart-legacy.txt
echo Create Partition Primary >> X:\diskpart-legacy.txt
echo Format FS=NTFS Label=OS Quick Override >> X:\diskpart-legacy.txt
echo Assign Letter=C >> X:\diskpart-legacy.txt

diskpart /s X:\diskpart-legacy.txt

Set OSPART=%OSPART%:

if exist d:\PreStagedMedia.wim ( dism.exe /apply-image /imagefile:d:\PreStagedMedia.wim /applydir:%OSPART% /index:1 )
if exist e:\PreStagedMedia.wim ( dism.exe /apply-image /imagefile:e:\PreStagedMedia.wim /applydir:%OSPART% /index:1 )
if exist f:\PreStagedMedia.wim ( dism.exe /apply-image /imagefile:f:\PreStagedMedia.wim /applydir:%OSPART% /index:1 )
if exist g:\PreStagedMedia.wim ( dism.exe /apply-image /imagefile:g:\PreStagedMedia.wim /applydir:%OSPART% /index:1 )
if exist h:\PreStagedMedia.wim ( dism.exe /apply-image /imagefile:h:\PreStagedMedia.wim /applydir:%OSPART% /index:1 )
if exist i:\PreStagedMedia.wim ( dism.exe /apply-image /imagefile:i:\PreStagedMedia.wim /applydir:%OSPART% /index:1 )

if NOT exist %OSPART%\Windows (
	echo "Apply PreStagedMedia.WIM failed.. check if media was assigned to either d/e/f/g drive letters.."
	pause
	exit
	)

md %OSPART%\Windows\Temp\Mount
DISM.exe /Mount-Image /ImageFile:%OSPART%\sources\boot.wim /Index:1 /MountDir:%OSPART%\Windows\Temp\Mount

echo Select Disk 0 > %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-legacy.txt
echo Select Partition 1 >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-legacy.txt
echo Assign Letter=S >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-legacy.txt
echo Select Partition 2 >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-legacy.txt
echo Assign Letter=C >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-legacy.txt
echo Exit >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-legacy.txt
del %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini /q /f
echo [LaunchApps] >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo %windir%\system32\diskpart.exe, /s x:\windows\temp\diskpart-legacy.txt >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\sms\bin\x64\TsBootShell.exe >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini

DISM.exe /Unmount-Image /MountDir:%OSPART%\Windows\Temp\Mount /Commit
rmdir %OSPART%\windows\temp\mount /s /q

bcdboot.exe %OSPART%\windows /s S: /f BIOS
cmd.exe /c del S:\%BCDDir%\BCD /f /q
cmd.exe /c copy %OSPART%\%BCDDir%\BCD S:\%BCDDir% /y
bcdedit.exe /Store S:\%BCDDir%\BCD /Set {ramdiskoptions} ramdisksdidevice partition=%OSPART%
bcdedit.exe /Store S:\%BCDDir%\BCD /Set {Default} device ramdisk=[%OSPART%]\sources\boot.wim,{ramdiskoptions}
bcdedit.exe /Store S:\%BCDDir%\BCD /Set {Default} osdevice ramdisk=[%OSPART%]\sources\boot.wim,{ramdiskoptions}
bcdedit.exe /store S:\%BCDDir%\BCD -set {bootmgr} device partition=S:
REM for /f "tokens=1,2,3" %%a in ('bcdedit.exe -store S:\EFI\Microsoft\Boot\BCD -create /d "Windows PE" /application osloader') Do bcdedit.exe -store S:\EFI\Microsoft\Boot\BCD /default %%c