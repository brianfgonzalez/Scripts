@echo off
setlocal

SET BCDEDIT=bcdedit.exe
SET BCDSTORE=C:\Boot\BCD
SET SDI_FILE=boot.sdi
SET WIM_File=boot.wim
SET RECDRV=%1

attrib c:\bootmgr -H -S
del c:\bootmgr /F
copy %RECDRV%\bootmgr c:\bootmgr
del c:\boot\bcd /F

attrib c:\boot\bcd -H -S
del c:\boot\bcd /F
%BCDEDIT% /createstore c:\boot\bcd

echo.
echo Adding {BootMgr} entries
echo ===========
echo.

%BCDEDIT% /store %BCDSTORE% /create {bootmgr}
%BCDEDIT% /store %BCDSTORE% /set {bootmgr} description "Boot Manager"
%BCDEDIT% /store %BCDSTORE% /set {bootmgr} device partition=C:
REM %BCDEDIT% /store %BCDSTORE% /set {bootmgr} path  \bootmgr
%BCDEDIT% /store %BCDSTORE% /set {bootmgr} timeout 20
%BCDEDIT% /store %BCDSTORE% /set {bootmgr} DisplayBootMenu true

echo.
echo Adding Ram Disk Options
echo ===========


for /f "Tokens=3" %%A in ('%BCDEDIT% /store %BCDSTORE% /create /device') do set ramdisk=%%A 

%BCDEDIT% /store %BCDSTORE% /set %ramdisk% ramdisksdidevice partition=%RECDRV%
%BCDEDIT% /store %BCDSTORE% /set %ramdisk% ramdisksdipath \boot\boot.sdi 
echo.

echo.
echo Adding Win 7
echo ===========
echo.

for /f "Tokens=3" %%A in ('%BCDEDIT% /store %BCDSTORE% /create /application osloader') do set GUID=%%A

echo.
echo win7 guid=%GUID%
echo.

%BCDEDIT% /store %BCDSTORE% /set %GUID% device boot
%BCDEDIT% /store %BCDSTORE% /set %GUID% systemroot \Windows
%BCDEDIT% /store %BCDSTORE% /set %GUID% osdevice boot
%BCDEDIT% /store %BCDSTORE% /set %GUID% path \Windows\system32\winload.exe
%BCDEDIT% /store %BCDSTORE% /set %GUID% description "Windows OS"
%BCDEDIT% /store %BCDSTORE% /set %GUID% nx OptIn
REM %BCDEDIT% /store %BCDSTORE% /set %GUID% inherit {bootloadersettings}
%BCDEDIT% /store %BCDSTORE% /displayorder %GUID%

echo.
echo Adding Win PE
echo ===========
echo.

for /f "Tokens=3" %%A in ('%BCDEDIT% /store %BCDSTORE% /create /application osloader') do set GUID=%%A

echo.
echo winpe guid=%GUID%
echo.

%BCDEDIT% /store %BCDSTORE% /set %GUID% systemroot \Windows
%BCDEDIT% /store %BCDSTORE% /set %GUID% detecthal Yes
%BCDEDIT% /store %BCDSTORE% /set %GUID% winpe Yes
%BCDEDIT% /store %BCDSTORE% /set %GUID% osdevice ramdisk=[%RECDRV%]\Sources\boot.wim,%ramdisk%
%BCDEDIT% /store %BCDSTORE% /set %GUID% device ramdisk=[%RECDRV%]\Sources\boot.wim,%ramdisk%
%BCDEDIT% /store %BCDSTORE% /set %GUID% description "Windows PE"
%BCDEDIT% /store %BCDSTORE% /displayorder %guid% /addlast

echo.
echo.
endlocal
