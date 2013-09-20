REM Build Custom WinPE Script was updated to support WinPE 4.0 (Win8 PE)
REM Dated: Nov 28, 2012
REM Authored: Brian Gonzalez

REM Run from Windows AIK Command Prompt
SET DRIVERLOC="%~dp0drivers"
SET WPPATH=="%~dp0winpe.bmp"
SET SYS32FILES="%~dp0System32"

REM Change Dir to Dep Tools
cd /d "C:\Program Files (x86)\Windows Kits\8.0\Assessment and Deployment Kit\Deployment Tools"

REM Set PE Tools ENV Variables
call DandISetEnv.bat

REM Un-mount any previous mounts to C:\WinPEx86\mount
imagex /unmount "C:\WinPEx86\mount"

REM Delete Working PE Build folder if exists
rd c:\WinPEx86 /s/q

REM Create PE Boot .WIM
call copype.cmd x86 C:\WinPEx86

REM Mount Boot.WIM to Mount Folder
Dism /mount-image /imagefile:C:\WinPEx86\media\sources\boot.wim /index:1 /mountdir:C:\WinPEx86\mount

REM Copy Custom files to inside mounted WIM folder (incl. custom startnet.cmd file)
copy %WPPATH% "c:\WinPEx86\mount\Windows\system32\winpe.bmp" /y
xcopy %SYS32FILES%\*.* "c:\WinPEx86\mount\Windows\system32\" /heyi

REG LOAD "HKLM\Winpe" "c:\WinPEx86\mount\Windows\system32\config\default" 
REG ADD "HKLM\winpe\Control Panel\Desktop" /v "Wallpaper" /d "%%systemroot%%\system32\winpe.bmp" /t "REG_SZ" /F
REG UNLOAD "HKLM\Winpe"

REM Add commonly used packages to mounted WIM
cd /d "C:\Program Files (x86)\Windows Kits\8.0\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs"
dism /Image:C:\WinPEx86\mount /Add-Package /packagepath:"WINPE-DOT3SVC.CAB"
dism /Image:C:\WinPEx86\mount /Add-Package /packagepath:"en-us\WINPE-DOT3SVC_EN-US.CAB"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-Scripting.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-Scripting_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-WMI.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-WMI_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-MDAC.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-MDAC_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-HTA.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-HTA_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-NetFx4.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-NetFx4_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-PowerShell3.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-PowerShell3_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-DismCmdlets.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-DismCmdlets_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-StorageWMI.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-StorageWMI_en-us.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-WinReCfg.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-WinReCfg.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-SRT.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-SRT.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-Rejuv.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-Rejuv.cab"
REM dism /image:C:\WinPEx86\mount /add-package /packagepath:"WinPE-Setup.cab"
REM dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\WinPE-Setup.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"Winpe-LegacySetup.cab"
dism /image:C:\WinPEx86\mount /add-package /packagepath:"en-us\Winpe-LegacySetup.cab"

REM Add All Drivers from Drivers sub-folder
DISM.exe /image:C:\WinPEx86\mount /add-driver /driver:%DRIVERLOC% /recurse

echo wpeutil reboot>"c:\WinPEx86\mount\Windows\system32\reboot.bat"
echo wpeutil shutdown>"c:\WinPEx86\mount\Windows\system32\shutdown.bat"
echo trace32.exe>"c:\WinPEx86\mount\Windows\system32\trace.bat"
echo ghost32_v11_win.exe>"c:\WinPEx86\mount\Windows\system32\ghost.bat"

REM Unmount Image and Commit Changes
DISM.exe /Unmount-Image /MountDir:c:\WinPEx86\mount /Commit

@echo .
@echo Final WinPEx86 Files were created to: C:\WinPEx86\media
pause