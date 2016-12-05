REM Download and extract SetACL.exe to same directory as CrazyWinPEMouseFix.bat ( https://helgeklein.com/download/#setacl )
if not exist "%~dp0SetACL.exe" ( goto NoSetACL )
"%~dp0SetACL.exe" -on "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" -ot reg -actn setowner -ownr "n:Administrators"
"%~dp0SetACL.exe" -on "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" -ot reg -actn ace -ace "n:Administrators;p:full"
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "4G" /t "REG_DWORD" /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\DefaultMediaCost" /v "3G" /t "REG_DWORD" /d 1 /f
pause
exit /b

:NoSetACL
echo "%~dp0SetACL.exe not found.  Exiting script."
pause
exit /b