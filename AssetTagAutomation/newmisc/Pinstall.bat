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

if /i "%1"  == "-AuditUser" (
    if "%2" == "0200" call :AuditUser_0200
) else if "%1"=="" (
    call :AuditUser_0200
) else goto END

:END
endlocal
echo ----- end: %date% %time% >> log.txt
goto :eof

:AuditUser_0200
start /b /wait pnputil -i -a newmisc.inf
if errorlevel 1 echo "%date% ERRORLEVEL:%ERRORLEVEL%" >> log.txt
exit /b


