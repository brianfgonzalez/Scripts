$sWSNAMECmdPath = @WindowsDir & "\Temp\wsname.exe"
RunWait("cmd.exe /k " & $sWSNAMECmdPath & " /RESPACE /N:STUTAB$SERIALNUM[6+] /LOG WSNAME.txt")