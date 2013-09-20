@echo off
setlocal

SET BCDEDIT=bcdedit.exe
SET BCDSTORE=C:\Boot\BCD
SET SDI_FILE=boot.sdi
SET WIM_File=boot.wim

attrib c:\bootmgr -H -S
del c:\bootmgr /F
copy r:\bootmgr c:\bootmgr
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
%BCDEDIT% /store %BCDSTORE% /set {bootmgr} device boot
%BCDEDIT% /store %BCDSTORE% /set {bootmgr} timeout 20

echo.
echo Adding Ram Disk Options
echo ===========


for /f "tokens=3" %%A in ('%BCDEDIT% /store %BCDSTORE% /create /device') do set ramdisk=%%A 

%BCDEDIT% /store %BCDSTORE% /set %ramdisk% ramdisksdidevice partition=R:
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

%BCDEDIT% /store %BCDSTORE% /set %GUID% device partition=C:
%BCDEDIT% /store %BCDSTORE% /set %GUID% systemroot \Windows
%BCDEDIT% /store %BCDSTORE% /set %GUID% osdevice partition=C:
%BCDEDIT% /store %BCDSTORE% /set %GUID% path \Windows\system32\winload.exe
%BCDEDIT% /store %BCDSTORE% /set %GUID% detecthal Yes
%BCDEDIT% /store %BCDSTORE% /set %GUID% description "Windows OS"
%BCDEDIT% /store %BCDSTORE% /displayorder %GUID%

echo.
echo Adding Win PE
echo ===========
echo.

for /f "Tokens=3" %%A in ('%BCDEDIT% /store %BCDSTORE% /create /application osloader') do set GUID=%%A

echo.
echo win7 guid=%GUID%
echo.

%BCDEDIT% /store %BCDSTORE% /set %GUID% systemroot \Windows
%BCDEDIT% /store %BCDSTORE% /set %GUID% detecthal Yes
%BCDEDIT% /store %BCDSTORE% /set %GUID% winpe Yes
%BCDEDIT% /store %BCDSTORE% /set %GUID% osdevice ramdisk=[R:]\Sources\boot.wim,%ramdisk%
%BCDEDIT% /store %BCDSTORE% /set %GUID% device ramdisk=[R:]\Sources\boot.wim,%ramdisk%
%BCDEDIT% /store %BCDSTORE% /set %GUID% description "Windows PE"
%BCDEDIT% /store %BCDSTORE% /displayorder %guid% /addlast

echo.
echo.
endlocal