@echo off

for %%d in (c d e f g h i j k l m n o p q r s t u v w x y z) do if exist %%d:\MININT\Scripts\LTIBootstrap.vbs (
echo %DATE%-%TIME% TSMBootstrap did not request reboot, resetting registry >> %%d:\MININT\SMSOSD\OSDLOGS\SetupRollback.log 
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v Win10UpgradeStatusCode /t REG_SZ /d "Failure" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\Setup" /v SetupType /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\Setup" /v CmdLine /t REG_SZ /d "" /f
echo %DATE%-%TIME% Launching TSMBootstrapper to fininsh TS >> %%d:\MININT\SMSOSD\OSDLOGS\SetupRollback.log
wscript.exe %%d:\MININT\Scripts\LTIBootstrap.vbs ) 