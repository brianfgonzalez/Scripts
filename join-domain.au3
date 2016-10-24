;Please specify account with rights to add mcomputer to domain and rights to move computer object to Netmotion OU
$DomainUsername = "" ;ie joinaccount
$DomainPassword = "" ;ie P@ssw0rd
$LogonDomain = "" ;ie company
$JoinDomain = "" ;ie company.org

;Copying netdom utility to c:\Windows\System32 of target machine
RunWait(@ComSpec & " /c xcopy """ & @ScriptDir & "\netdom\*.*"" ""C:\Windows\System32\"" /heyi", @ScriptDir, @SW_HIDE)

;Admin computer to Domain
RunWait(@ComSpec & " /c netdom join """ & @ComputerName & """ /Domain:""" & $JoinDomain & """ /UserD:""" & $LogonDomain & "\" & $DomainUsername & """ /PasswordD:""" & $DomainPassword & """", @WindowsDir, @SW_HIDE)

;Sleeping to ensure computer is fully added to domain before move
Sleep(20000)

;Moving computer object to Netmotion OU in VNSNY Domain
RunAsWait($DomainUsername, $LogonDomain, $DomainPassword, 1, "cscript """ & @ScriptDir & "\moveou.vbs""", @WindowsDir, @SW_HIDE)