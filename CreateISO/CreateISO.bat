SET CONTENT=D:\Customer\AirForce\3.5\Disc2
SET ISOPATH=D:\Customer\AirForce\3.5\SDC-3.4x64_Disc2of2_315_198_541.ISO

REM Change Dir to Dep Tools 8.0
cd /d "C:\Program Files (x86)\Windows Kits\8.0\Assessment and Deployment Kit\Deployment Tools"
REM Set PE Tools ENV Variables
call DandISetEnv.bat

REM Change Dir to Dep Tools 8.1
cd /d "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools"
REM Set PE Tools ENV Variables
call DandISetEnv.bat

REM Change Dir to Dep Tools 10
cd /d "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools"
REM Set PE Tools ENV Variables
call DandISetEnv.bat

oscdimg.exe -lAGM -m -u2 -yo"%~dp0BootOrder.txt" -b"%~dp0etfsboot.com" "%CONTENT%" "%ISOPATH%"

@echo .
@echo Final Bootable ISO created.
pause