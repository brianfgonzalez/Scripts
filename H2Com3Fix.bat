@echo off
If "%PROCESSOR_ARCHITECTURE%" EQU "x86" (
    If exist "%SystemRoot%\SysWOW64" (
        "%SystemRoot%\sysnative\cmd.exe" /C "%~dpnx0" %1 %2 %3 %4 %5 %6 %7 %8 %9
        exit
    )
)

cd /d %~dp0

REM devcon.exe pulled from "GRMWDK_EN_7600_1.ISO" (WDK)
REM Perform Devcon Remove on AMT device.
"%~dp0devcon.exe" remove "PCI\VEN_8086&DEV_1C3D"

REM Perform Devcon Remove of Serial to USB device
"%~dp0devcon.exe" remove "USB\VID_10C4&PID_EA60*"
"%~dp0devcon.exe" remove "USB\VID_10C4&PID_EA70*"

REM "%~dp0devcon-x86.exe" remove "PCI\VEN_8086&DEV_1C3D"

REM Import Reg that forces Com3 to inUse state.
"%WinDir%\system32\reg.exe" import "%~dp0COM3-InUse.reg"

REM Timeout for 5 seconds to allow device to be fully removed.
timeout /T 5

REM Perform Device Scan to re-Discover AMT device.
"%~dp0devcon.exe" rescan