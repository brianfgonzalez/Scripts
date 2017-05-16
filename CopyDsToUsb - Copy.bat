@setlocal enableextensions enabledelayedexpansion
@echo off

REM Variables that require updating
SET OsWimName=7x86ProVL-2016Jul28
SET DrvLetter=F:

REM Optional Variables
REM Set to yes if you wish to delete the Os wims from Usb prior to update
SET DelOsWim=N

REM Do NOT change these variables
REM Get scriptdir withOUT trailing backslash
SET scriptdir=%~dp0
SET scriptdir=%scriptdir:~0,-1%
SET mountdir=c:\tmpmnt
SET XF="LiteTouchPE*.wim" "*.iso" "*Media*.bat" MDT*.application *Sorter.ps1 CreateISO.bat autorun.inf
SET XD="%scriptdir%\Deploy\Working" "%scriptdir%\Deploy\Captures" "%scriptdir%\Deploy\Operating Systems"
SET UsbBootWim64=%~dp0Deploy\Boot\USBLtPe_x64.wim
SET UsbBootWim86=%~dp0Deploy\Boot\USBLtPe_x86.wim

REM Del existing Os Wims if exists, this makes sure that Rc doesn't fail on low disk space check
IF %DelOsWim%=="Y" (
IF EXIST "F:\Deploy\Operating Systems" RD "F:\Deploy\Operating Systems" /S /Q
)

REM Update all content excluding Os Imgs and Boot Imgs
robocopy "%scriptdir%" "%DrvLetter%" /e /purge /sl /a-:hs /mt /purge /v /fp /eta /xf %XF% /xd %XD%

REM Copy ONLY the desired OS Wim
robocopy "%scriptdir%" "%DrvLetter%" %OsWimName%*.swm %OsWimName%*.wim  /e
REM if error on wim may need to be split to fit on Fat32
IF %ERRORLEVEL% GTR 1 CALL :ERROR "failed(%ERRORLEVEL%) to copy Os image."

IF EXIST "%~dp0Deploy\Boot\LiteTouchPE_x64.wim" GOTO :Bootx64
GOTO :Bootx86

REM Bootx64 Section
REM Copy Orig LiteTouchPE Wim to begin creating media Wim
copy "%~dp0Deploy\Boot\LiteTouchPE_x64.wim" "%UsbBootWim64%" /y
REM Mount USBLtPe_x64.wim to inject media bootstrap.ini
IF NOT EXIST "%mountdir%" (md "%mountdir%")
dism /mount-image /imagefile:"%UsbBootWim64%" /index:1 /mountdir:"%mountdir%"
IF %ERRORLEVEL% GTR 0 CALL :ERROR "failed(%ERRORLEVEL%) to mount %UsbBootWim64% wim."

:Bootx86
REM Bootx64 Section
REM Copy Orig LiteTouchPE Wim to begin creating media Wim
copy "%~dp0Deploy\Boot\LiteTouchPE_x86.wim" "%UsbBootWim64%" /y
REM Mount USBLtPe_x64.wim to inject media bootstrap.ini
IF NOT EXIST "%mountdir%" (md "%mountdir%")
dism /mount-image /imagefile:"%UsbBootWim86%" /index:1 /mountdir:"%mountdir%"
IF %ERRORLEVEL% GTR 0 CALL :ERROR "failed(%ERRORLEVEL%) to mount %UsbBootWim86% wim."

REM Overwrite Bootstrap,ini file in Boot wim
echo [Settings]> "%mountdir%\Deploy\scripts\Bootstrap.ini"
echo Priority=Default>> "%mountdir%\Deploy\scripts\Bootstrap.ini"
echo [Default]>> "%mountdir%\Deploy\scripts\Bootstrap.ini"
echo SkipBDDWelcome=YES>> "%mountdir%\Deploy\scripts\Bootstrap.ini"

REM Unmount Litetouch WIM image
dism /unmount-image /mountdir:%mountdir% /commit
REM if error on unmount, exit script
IF %ERRORLEVEL% GTR 0 CALL :ERROR "failed(%ERRORLEVEL%) to un-mount %UsbBootWim64% wim."

IF EXIST "%UsbBootWim64%" copy "%UsbBootWim64%" "%DrvLetter%\Deploy\Boot\LiteTouchPE_x64.wim" /y
IF EXIST "%UsbBootWim86%" copy "%UsbBootWim86%" "%DrvLetter%\Deploy\Boot\LiteTouchPE_x86.wim" /y

REM Create media.tag file
echo.> "%DrvLetter%\Deploy\Scripts\media.tag"

REM Overwrite Bootstrap,ini file outside of Boot wim
echo [Settings]> "%DrvLetter%\Deploy\Control\Bootstrap.ini"
echo Priority=Default>> "%DrvLetter%\Deploy\Control\Bootstrap.ini"
echo [Default]>> "%DrvLetter%\Deploy\Control\Bootstrap.ini"
echo SkipBDDWelcome=YES>> "%DrvLetter%\Deploy\Control\Bootstrap.ini"

label %DrvLetter% %sWimName%

echo Script completed with no errors...
pause
exit

:ERROR
echo %1
pause
exit
