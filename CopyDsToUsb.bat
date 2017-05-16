@setlocal enableextensions enabledelayedexpansion
@echo off

REM Variables that require updating
SET OsWimName=
SET DrvLetter=F:

REM Optional Variables
REM Set to yes if you wish to delete the Os wims from Usb prior to update
SET DelOsWim=Y

REM Do NOT change these variables
REM Get scriptdir withOUT trailing backslash
SET scriptdir=%~dp0
SET scriptdir=%scriptdir:~0,-1%
SET mountdir=c:\tmpmnt
SET XF="LiteTouchPE*.wim" "*.iso" "*Media*.bat" MDT*.application *Sorter.ps1 CreateISO.bat autorun.inf
SET XD="%scriptdir%\Deploy\Working" "%scriptdir%\Deploy\Captures" "%scriptdir%\Deploy\Operating Systems"

REM Del existing Os Wims if exists, this makes sure that Rc doesn't fail on low disk space check
IF %DelOsWim%=="Y" (
IF EXIST "F:\Deploy\Operating Systems" RD "F:\Deploy\Operating Systems" /S /Q
)

REM Update all content excluding Os Imgs and Boot Imgs
robocopy "%scriptdir%\Deploy" "%DrvLetter%\Deploy" /e /purge /sl /a-:hs /mt /purge /v /fp /eta /xf %XF% /xd %XD%

REM Copy ONLY the desired OS Wim
robocopy "%scriptdir%\Deploy" "%DrvLetter%\Deploy" %OsWimName%*.swm %OsWimName%*.wim  /e
REM if error on wim may need to be split to fit on Fat32
IF %ERRORLEVEL% GTR 1 CALL :ERROR "failed(%ERRORLEVEL%) to copy Os image."

echo Script completed with no errors...
pause
exit

:ERROR
echo %1
pause
exit