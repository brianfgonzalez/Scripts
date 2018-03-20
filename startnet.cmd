@echo off

for %%d in (c d e f g h i j k l m n o p q r s t u v w x y z) do if exist %%d:\PreStagedMedia.swm (set USBDisk=%%d:)
if not exist %USBDisk%\PreStagedMedia.swm @echo PreStagedMedia.swm not found.. && timeout /t 30 && exit
@echo %USBDisk%\PreStagedMedia.swm was found.. So Disk preperation will now begin..
echo select disk 0 >%TEMP%\diskpart.txt
echo clean >>%TEMP%\diskpart.txt
echo convert gpt >>%TEMP%\diskpart.txt
echo create partition efi size=100 >>%TEMP%\diskpart.txt
echo format quick fs=fat32 label="Boot" >>%TEMP%\diskpart.txt
echo assign letter="S" >>%TEMP%\diskpart.txt
echo create partition msr size=128 >>%TEMP%\diskpart.txt
echo create partition primary >>%TEMP%\diskpart.txt
echo format quick fs=ntfs label="Windows" >>%TEMP%\diskpart.txt
echo assign letter="W" >>%TEMP%\diskpart.txt
diskpart /s %TEMP%\diskpart.txt
@echo Disk preperation is complete.. SWM will now be applied to W:\..
dism /Apply-Image /ImageFile:%USBDisk%\PreStagedMedia.swm /SWMFile:%USBDisk%\PreStagedMedia*.swm /index:1 /applydir:W:\
bcdboot W:\Windows /s S:
@echo Imaging of %USBDisk%\PreStagedMedia.swm to W:\ is complete..Remove USB drive.. Shutting down in 20 sec..
@wpeutil shutdown