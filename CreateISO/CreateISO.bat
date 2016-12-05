SET CONTENT=D:\Customer\Memphis\MemphisMedia_2016Nov06\Content
SET ISOPATH=D:\Customer\Memphis\MemphisMedia_2016Nov06\MemphisMedia_2016Nov06.ISO

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

del "%ISOPATH%" /f/q
oscdimg.exe -lMemphis -m -u2 -yo"%~dp0BootOrder.txt" -b"%~dp0etfsboot.com" "%CONTENT%" "%ISOPATH%"

@echo .
@echo Final Bootable ISO created.
pause