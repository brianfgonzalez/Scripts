wpeinit

Set BCDDir=EFI\Microsoft\Boot
Set BCDBootOption=UEFI
Set OSPART=C

echo select disk 0 > X:\diskpart-efi.txt
echo clean >> X:\diskpart-efi.txt
echo convert GPT >> X:\diskpart-efi.txt
echo create partition EFI size=200 >> X:\diskpart-efi.txt
echo format quick fs=fat32 label=EFI >> X:\diskpart-efi.txt
echo assign letter=S >> X:\diskpart-efi.txt
echo create partition MSR size=128 >> X:\diskpart-efi.txt
echo create partition primary >> X:\diskpart-efi.txt
echo format quick fs=ntfs label=Windows >> X:\diskpart-efi.txt
echo assign letter=%OSPART% >> X:\diskpart-efi.txt

diskpart /s X:\diskpart-efi.txt

Set OSPART=%OSPART%:

if exist d:\PreStagedMedia.swm ( dism.exe /apply-image /imagefile:d:\PreStagedMedia.swm /swmfile:d:\PreStagedMedia*.swm /applydir:%OSPART% /index:1 )
if exist e:\PreStagedMedia.swm ( dism.exe /apply-image /imagefile:e:\PreStagedMedia.swm /swmfile:e:\PreStagedMedia*.swm /applydir:%OSPART% /index:1 )
if exist f:\PreStagedMedia.swm ( dism.exe /apply-image /imagefile:f:\PreStagedMedia.swm /swmfile:f:\PreStagedMedia*.swm /applydir:%OSPART% /index:1 )
if exist g:\PreStagedMedia.swm ( dism.exe /apply-image /imagefile:g:\PreStagedMedia.swm /swmfile:g:\PreStagedMedia*.swm /applydir:%OSPART% /index:1 )

if NOT exist %OSPART%\Windows (
	echo "Apply PreStagedMedia.SWM failed.. check if media was assigned to either d/e/f/g drive letters.."
	pause
	exit
	)

md %OSPART%\Windows\Temp\Mount
DISM.exe /Mount-Image /ImageFile:%OSPART%\sources\boot.wim /Index:1 /MountDir:%OSPART%\Windows\Temp\Mount
echo Select Disk 0 > %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-efi.txt
echo Select Partition 1 >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-efi.txt
echo Select Partition 2 >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-efi.txt
echo Assign Letter=S >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-efi.txt
echo Exit >> %OSPART%\Windows\Temp\Mount\Windows\temp\diskpart-efi.txt

del %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini /q /f
echo [LaunchApps] >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\diskpart.exe, /s x:\windows\temp\diskpart-efi.txt >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\xcopy.exe, /e S:\EFI\*.* %OSPART%\Windows\temp\EFIOrg\*.* /H /Y >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\sms\bin\x64\TsBootShell.exe >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\sms\bin\i386\TsBootShell.exe >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\diskpart.exe, /s x:\windows\temp\diskpart-efi.txt >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\xcopy.exe, /e S:\EFI\*.* %OSPART%\Windows\temp\EFINew\*.* /H /Y >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\xcopy.exe, /e %OSPART%\Windows\temp\EFIOrg\*.* S:\EFI\*.* /H /Y >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\xcopy.exe, /e %OSPART%\Windows\temp\EFINew\*.* S:\EFI\*.* /H /Y >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\cmd.exe, /c rmdir %OSPART%\Windows\temp\EFIOrg /s /q >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
echo x:\windows\system32\cmd.exe, /c rmdir %OSPART%\Windows\temp\EFINew /s /q >> %OSPART%\Windows\Temp\Mount\Windows\System32\winpeshl.ini
DISM.exe /Unmount-Image /MountDir:%OSPART%\Windows\Temp\Mount /Commit
rmdir %OSPART%\windows\temp\mount /s /q

bcdboot.exe %OSPART%\windows /s S: /f %BCDBootOption%
cmd.exe /c del S:\%BCDDir%\BCD /f /q
cmd.exe /c copy %OSPART%\%BCDDir%\BCD S:\%BCDDir% /y
bcdedit.exe /Store S:\%BCDDir%\BCD /Set {ramdiskoptions} ramdisksdidevice partition=%OSPART%
bcdedit.exe /Store S:\%BCDDir%\BCD /Set {Default} device ramdisk=[%OSPART%]\sources\boot.wim,{ramdiskoptions}
bcdedit.exe /Store S:\%BCDDir%\BCD /Set {Default} osdevice ramdisk=[%OSPART%]\sources\boot.wim,{ramdiskoptions}
bcdedit.exe /store S:\%BCDDir%\BCD -set {bootmgr} device partition=S:
for /f "tokens=1,2,3" %%a in ('bcdedit.exe -store S:\EFI\Microsoft\Boot\BCD -create /d "Windows PE" /application osloader') Do bcdedit.exe -store S:\EFI\Microsoft\Boot\BCD /default %%c
