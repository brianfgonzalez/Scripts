@echo off
If "%PROCESSOR_ARCHITECTURE%" EQU "x86" (
    If exist "%SystemRoot%\SysWOW64" (
        "%SystemRoot%\sysnative\cmd.exe" /C "%~dpnx0" %1 %2 %3 %4 %5 %6 %7 %8 %9
        exit
    )
)
cd /d %~dp0
echo ----- start: %date% %time% >> log.txt
echo %~dp0 >> log.txt
setlocal

if /i "%1"  == "-FirstLogon" (
    if "%2" == "0217" call :FirstLogon_0217
) else if "%1"=="" (
    call :FirstLogon_0217
) else goto END

:END
endlocal
echo ----- end: %date% %time% >> log.txt
goto :eof

:FirstLogon_0217
>> log.txt echo cmd: Win10/64bit/GssdInst.exe install port:3 baud:9600 vport:0
start /b /wait Win10/64bit/GssdInst.exe install port:3 baud:9600 vport:0
if errorlevel 1 echo "%date% ERRORLEVEL:%ERRORLEVEL%" >> log.txt
exit /b


