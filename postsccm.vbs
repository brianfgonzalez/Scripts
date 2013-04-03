'==========================================================================
'
' NAME: Postsccm.vbs
'
' AUTHOR: Brian Gonzalez
' DATE  : 11.21.2012
'
'
' Changlog:
' 11.21.12 - First revision
'
' PURPOSE: Build a static image to ease the transfer to Heartland.
'==========================================================================
On Error Resume Next
'Setup Objects, Constants and Variables.
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = WScript.CreateObject("WScript.Shell")
Set objWMI = GetObject("winmgmts:")
Set objWMIService = GetObject("winmgmts:\\.\root\CIMV2")
Const ForReading = 1, ForWriting = 2, ForAppending = 8
versionNumber = "1.0"
scriptFolder = objFSO.GetParentFolderName(Wscript.ScriptFullName)
currstepPath = scriptFolder & "\currStep.txt"

'Exit script if running user is not an admin
If Not CSI_IsAdmin() Then
	logHelper "User is not an Administrator. Exiting script.", ""
	Wscript.Quit
End If

If objFSO.FileExists(currstepPath) Then
	Set objcurrStep = objFSO.OpenTextFile(currstepPath, 1, True)
	'WScript.Echo Trim(objcurrStep.ReadAll)
	process(Trim(objcurrStep.ReadAll))
Else
	process("Sysprep")
End If

Sub process(currStep)
	Select Case currStep
	Case "Sysprep"
		'WScript.Echo "Run Sysprep"
		logHelper "Sysprep Flag found...", ""

		'Prepare file to startup with First Logon section.
		Set objcurrStep = objFSO.CreateTextFile(currstepPath, True)		
		objcurrStep.Write("FirstLogon")

		'Set up shortcut to script in Startup Folder.
		createShortcut()

		'Set up AutoLogon Entries.
		logHelper "Set up AutoLogon Entries", "begin"
		objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon", "1", "REG_DWORD"
		objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultUserName", "Administrator", "REG_SZ"
		objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultDomainName", "%ComputerName%", "REG_SZ"
		objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultPassword", "P@ssw0rd", "REG_SZ"
		logHelper "Set up AutoLogon Entries", err.Number
		
		'Notify Tech that Sysprep is coming next.
		objShell.Popup "Sysprep will now run, please capture GHO image once shutdown is complete.", 20, "Sysprep coming next...", 64
		
		'Run Sysprep and perform shutdown
		logHelper "Run Sysprep and Shutdown", "begin"
		'sRet = objShell.Run("""C:\Windows\System32\sysprep\sysprep.exe"" /quiet /oobe /generalize /shutdown /unattend:""" & scriptFolder & "\sysprep\unattend.xml""", 1, False)
		sRet = objShell.Run("""C:\Windows\System32\sysprep\sysprep.exe"" /quiet /oobe /generalize /reboot /unattend:""" & scriptFolder & "\sysprep\unattend.xml""", 1, False)
		logHelper "Run Sysprep and Shutdown", sRet

	Case "FirstLogon"
		'WScript.Echo "Run FirstLogon"
		logHelper "FirstLogon Flag found...", ""
		
		'Prepare current step text file to tell script to jump to SecondLogon
		Set objcurrStep = objFSO.CreateTextFile(currstepPath, True)
		objcurrStep.Write("SecondLogon")
		
		'Change Computer Name to Serial Number
		logHelper "Rename Computer Step", "begin"
		For Each bios In objWMI.InstancesOf("Win32_BIOS") 
			sNewname = "M" & bios.SerialNumber 
		Next
 		strComputer = "."
		Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2") 
		Set colComputers = objWMIService.ExecQuery ("Select * from Win32_ComputerSystem") 
		For Each objComputer In colComputers 
		    sRet = ObjComputer.Rename(sNewName)
		Next
		logHelper "Rename Computer Step", sRet
	
		'Add MAK license Key for Professional
		logHelper "Add Professional 7 KMS key", "begin"
		sCmd = "cscript.exe c:\windows\system32\slmgr.vbs /ipk MJHXM-GMC4C-6QHYH-YXTGQ-837GC"
		sRet = objShell.Run(sCmd, 0, True)
		logHelper "Add Professional 7 KMS key", sRet
		
		'Add MAK license Key for Professional
		logHelper "Perform Windows Activation", "begin"
		sCmd = "cscript.exe c:\windows\system32\slmgr.vbs /ato"
		sRet = objShell.Run(sCmd, 0, True)
		logHelper "Perform Windows Activation", sRet

		'Perform Reboot to begin SecondLogon scripts
		logHelper "Rebooting machine to perform 2nd logon configurations", "begin"
		sCmd = "shutdown -r -t 15 -f -c ""Rebooting machine to perform 2nd logon configurations and complete pc name change."""
		sRet = objShell.Run(sCmd, 1, False)
		logHelper "Rebooting machine to perform 2nd logon configurations", sRet
		
	Case "SecondLogon"
		'WScript.Echo "Run SecondLogon"
		logHelper "SecondLogon Flag found...", ""
		
		'Prepare current step text file to tell script to jump to ThirdLogon
		Set objcurrStep = objFSO.CreateTextFile(currstepPath, True)
		objcurrStep.Write("ThirdLogon")

		'Delay script 10 seconds to give system time to initiate network
		Wscript.Sleep 10000

		'Join computer to VNSNY domain
		logHelper "Join Securitas domain", "begin"
		sCmd = scriptFolder & "\account-changes\join-domain.exe"
		sRet = objShell.Run(sCmd, 0, True)
		logHelper "Join vnsny domain", sRet
		
		'Perform Reboot to begin ThirdLogon scripts
		logHelper "Perform reboot to begin 3rd logon", "begin"
		sCmd = "shutdown -r -t 15 -f -c ""Rebooting machine to complete domain join and begin 3rd login processing."""
		sRet = objShell.Run(sCmd, 1, False)
		logHelper "Perform reboot to begin 3rd logon", sRet
		
	Case "ThirdLogon"
		'WScript.Echo "Run ThirdLogon"
		logHelper "Thirdlogon Flag found...", ""
		
		'Prepare current step text file to tell script we are complete and not to rerun
		Set objcurrStep = objFSO.CreateTextFile(currstepPath, True)
		objcurrStep.Write("ForthLogin")

		'Check if OS is Win7 Enterprise or Professional
		If Is7Pro() Then
			logHelper "Install PGP", "begin"
			'Install PGP client
			sCmd = "msiexec /i """ & scriptFolder & "\pgp\PGPDesktopx64_10_2_15NOV2011.msi"" /qb- /norestart /log c:\windows\temp\pgp-install.log"
			sRet = objShell.Run(sCmd, 1, True)
			ReRunIfMSIWasRunning sCmd, sRet
			logHelper "Install PGP, see log for status c:\windows\temp\pgp-install.log", sRet
		Else
			'Running Enterprise, so BitLocker will be setup later in script
		End If

		'Install Altiris Components
		logHelper "Install Altiris Agent(AeXNSC.exe)", "begin"
		sCmd = scriptFolder & "\altiris\AeXNSC.exe -s /s /install /path=""C:\Program Files (x86)\Altiris"" /ns=""altirisw0301.vnsny.org"""
		sRet = objShell.Run(sCmd, 0, True)
		ReRunIfMSIWasRunning sCmd, sRet
		logHelper "Install Altiris Agent(AeXNSC.exe)", sRet

		logHelper "Install Altiris Agent(AMAgentSetup.msi)", "begin"
		sCmd = "msiexec.exe /i """ & scriptFolder & "\altiris\AMAgentSetup.msi"" /qn REBOOT=ReallySuppress ALLUSERS=1 /log c:\windows\temp\amagent-install.log"
		sRet = objShell.Run(sCmd, 0, True)
		ReRunIfMSIWasRunning sCmd, sRet
		logHelper "Install Altiris Agent(AMAgentSetup.msi), see log for status c:\windows\temp\amagent-install.log.", sRet

		logHelper "Symantec Inventory Agent", "begin"
		sCmd = "msiexec.exe /i """ & scriptFolder & "\altiris\Symantec_InventoryAgent_x86.msi"" /qn REBOOT=ReallySuppress ALLUSERS=1 /log c:\windows\temp\inventory-install.log"
		sRet = objShell.Run(sCmd, 0, True)
		ReRunIfMSIWasRunning sCmd, sRet
		logHelper "Symantec Inventory Agent, see log for status c:\windows\temp\inventory-install.log.", sRet
		
		logHelper "Altiris Powerscheme Agent", "begin"
		sCmd = "msiexec.exe /i """ & scriptFolder & "\altiris\Altiris_PowerSchemeAgent_x86.msi"" /qn REBOOT=ReallySuppress ALLUSERS=1 /log c:\windows\temp\pwscheme-install.log"
		sRet = objShell.Run(sCmd, 0, True)
		ReRunIfMSIWasRunning sCmd, sRet
		logHelper "Altiris Powerscheme Agent, see log for status.", sRet

		logHelper "Software Management Solution Agent", "begin"
		sCmd = "msiexec.exe /i """ & scriptFolder & "\altiris\Software Management Solution Agent_7_0_rev1.msi"" /qn ALLUSERS=1 /log c:\windows\temp\swmanage-install.log"
		sRet = objShell.Run(sCmd, 0, True)
		ReRunIfMSIWasRunning sCmd, sRet
		logHelper "Software Management Solution Agent, see log for status c:\windows\temp\swmanage-install.log.", sRet
		
		'logHelper "Software Virtualization Agent", "begin"
		'sCmd = "msiexec.exe /qb /i """ & scriptFolder & "\Software_Virtualization_Agent.msi"" REBOOT=ReallySuppress PRODUCT_KEY=byv5a-wkyrb-k99w6-8db04 ALTIRIS_NS=1 ALLUSERS=1"
		'sRet = objShell.Run(sCmd, 0, True)
		'logHelper "Software Virtualization Agent", sRet
		
		logHelper "Altiris Patch Management", "begin"
		sCmd = "msiexec.exe /i """ & scriptFolder & "\altiris\Altiris_PatchMgmtAgent_Win32_7_0.msi"" /qn REBOOT=ReallySuppress ALLUSERS=1 /log c:\windows\temp\patchmanage-install.log"
		sRet = objShell.Run(sCmd, 0, True)
		ReRunIfMSIWasRunning sCmd, sRet
		logHelper "Altiris Patch Management, see log for status c:\windows\temp\patchmanage-install.log.", sRet

		logHelper "PC AClient Install Manager", "begin"
		sCmd = scriptFolder & "\altiris\pcAAgent\pcAClientInstallManager.exe /iall"
		sRet = objShell.Run(sCmd, 0, True)
		ReRunIfMSIWasRunning sCmd, sRet
		logHelper "PC AClient Install Manager", sRet
		
		'logHelper "PC Anywhere Client", "begin"
		'sCmd = "msiexec.exe /i """ & scriptFolder & "\altiris\PCAnywhere_12.x_Tech182142.msi"" /qb"
		'sRet = objShell.Run(sCmd, 0, True)
		'logHelper "Altiris Patch Management", sRet

		If Not objFSO.FolderExists("C:\Program Files (x86)\Symantec\Symantec Endpoint Protection") Then		
			'Install SEP Client
			logHelper "Install SEP Client", "begin"
			sCmd = "msiexec /qb /i """ & scriptFolder & "\sepclient\Symantec AntiVirus Win64.msi"" REBOOT=ReallySuppress RUNLIVEUPDATE=0 /log ""c:\windows\temp\SymantecEP.log"""
			sRet = objShell.Run(sCmd, 1, True)
			ReRunIfMSIWasRunning sCmd, sRet
			logHelper "Install SEP Client, see log for status c:\windows\temp\SymantecEP.log", sRet
		Else
			logHelper "SEP Client Already installed", ""
		End If		
		
		'Initialize SEP
		logHelper "Initialize SEP", "begin"
		sCmd = scriptFolder & "\sep\sylinkdrop.exe -silent """ & scriptFolder & "\sep\Tablets_sylink.xml"""
		sRet = objShell.Run(sCmd, 1, True)
		logHelper "Initialize SEP", sRet

		If objFSO.FileExists("C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\smc.exe") Then
			logHelper "Execute -UpdateConfig", "begin"
			sCmd = """C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\smc.exe"" -updateconfig"
			sRet = objShell.Run(sCmd, 1, True)
			logHelper "Execute -UpdateConfig", sRet
		Else
			logHelper "SMC.exe not found, not updating config", ""
		End If
		
	
		'Perform Windows activation.
		logHelper "Perform Windows activation", "begin"
		sCmd = "cscript.exe c:\windows\system32\slmgr.vbs /ato"
		sRet = objShell.Run(sCmd, 1, True)
		logHelper "Perform Windows activation", sRet
	
		'Reset Admin Account password and create joindomain account
		logHelper "Reset local admin account", "begin"
		sCmd = scriptFolder & "\account-changes\local-account-changes.exe"
		sRet = objShell.Run(sCmd, 1, True)
		logHelper "Reset local admin account", sRet
		
		'Set up autoLogin with vendorimaging
		logHelper "Set up Domain autoLogin", "begin"
		sCmd = scriptFolder & "\account-changes\auto-login-domain-acct.exe"
		sRet = objShell.Run(sCmd, 1, True)
		logHelper "Set up Domain autoLogin", sRet

		'Perform Reboot to begin ForthLogon scripts
		logHelper "Perform reboot to begin 4th logon configurations.", "begin"
		sCmd = "shutdown -r -t 15 -f -c ""Rebooting machine and login with the vendorimaging domain account."""
		sRet = objShell.Run(sCmd, 1, False)
		logHelper "Perform reboot to begin 4th logon configurations", sRet

	Case "ForthLogin"
		'WScript.Echo "Run ForthLogon"
		logHelper "Forthlogon Flag found...", ""

		'Delay script 10 seconds to give system time to initiate network
		Wscript.Sleep 10000

		'Copy PCRS Install log files if they exist
		logLoc = "C:\penbase\logs"
		targetLoc = "\\FPSM0101.vnsny.org\IS_Vol2\Application Development\PenUpgrades\C1ImageXML\"
		If objFSO.FolderExists(logLoc) AND objFSO.FolderExists(targetLoc) Then
			logHelper "Copy PCRS install log", "begin"
			'sCmd = "c:\windows\system32\xcopy.exe """ & logLoc & "\*.*"" ""\\FPSM0101.vnsny.org\IS_Vol2\Application Development\PenUpgrades\C1ImageXML\"" /heyi"
			'sRet = objShell.Run(sCmd, 0, True)
			sRet = objFSO.CopyFile(logLoc & "\*.*", targetLoc, True)
			logHelper "Copy PCRS install log", err.Number
		End If

		If Is7Pro() Then
			'Prepare current step text file to tell script we are complete and not to rerun
			Set objcurrStep = objFSO.CreateTextFile(currstepPath, True)
			objcurrStep.Write("Complete")
		
			'Professional scripting section
			'Configure and start pgp encryption
			logHelper "Configure and start pgp encryption", "begin"
			sCmd = scriptFolder & "\pgp\PGPConfigSilent.exe"
			sRet = objShell.Run(sCmd, 1, True)
			logHelper "Configure and start pgp encryption", sRet
			
			logHelper "Kick off Job Finishe subRoutine", "begin"
			jobFinished()
			logHelper "Kick off Job Finishe subRoutine", err.Number
		Else
			'BitLocker scripting section

			'Prepare current step text file to tell script we have a fifthlogin
			Set objcurrStep = objFSO.CreateTextFile(currstepPath, True)
			objcurrStep.Write("FifthLogin")
			
			logHelper "Kick Off initialization of TPM chip and shutdown", "begin"
			sCmd = "c:\windows\system32\cscript.exe //NoLogo """ & scriptFolder & "\bitlocker\EnableBitLocker.vbs"" /on:tpm /rk:c:\ /l:c:\windows\temp\bitlockers.log /promptuser"
			sRet = objShell.Run(sCmd, 0, True)
			logHelper "Kick Off initialization of TPM chip and shutdown, see log for status c:\windows\temp\bitlockers.log", sRet	

		End If

	Case "FifthLogin"
			'Prepare current step text file to tell script we are complete and not to rerun
			Set objcurrStep = objFSO.CreateTextFile(currstepPath, True)
			objcurrStep.Write("Complete")

			logHelper "Finish BL Encryption configuration", "begin"
			sCmd = "c:\windows\system32\cscript.exe //NoLogo """ & scriptFolder & "\bitlocker\EnableBitLocker.vbs"" /on:tpm /rk:c:\ /l:c:\windows\temp\bitlockere.log /promptuser"
			sRet = objShell.Run(sCmd, 0, True)
			logHelper "Finish BL Encryption configuration, see log for status c:\windows\temp\bitlockere.log", sRet

			logHelper "Kick off Job Finishe subRoutine", "begin"
			jobFinished()
			logHelper "Kick off Job Finishe subRoutine", err.Number
		
	Case "Complete"
		logHelper "Complete Flag found...", ""
	End Select
End Sub

Sub createShortcut()
	Win7smPath = objShell.ExpandEnvironmentStrings("%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Startup")
	WinXPsmPath = objShell.ExpandEnvironmentStrings("%ALLUSERSPROFILE%\Start Menu\Programs\Startup")
	If objFSO.FolderExists(Win7smPath) Then
		smPath = Win7smPath
	ElseIf objFSO.FolderExists(WinXPsmPath) Then
		smPath = WinXPsmPath
	End If

	Set objShtCut = objShell.CreateShortcut _
	(smPath & "\postmdt.lnk")
	objShtCut.TargetPath = "%WinDir%\system32\Wscript.exe"
	objShtCut.Arguments = "//NoLogo """ & scriptFolder & "\postmdt.vbs"""
	objShtCut.Save
End Sub

Function Is7Pro()
	Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_OperatingSystem", "WQL", _
		wbemFlagReturnImmediately + wbemFlagForwardOnly)
	For Each objItem In colItems
		If Trim(objItem.Caption) = "Microsoft Windows 7 Professional" Then
		   	Is7Pro = True
		Else
		   	Is7Pro = False
		End If
	Next
End Function

Sub logHelper(stepName, sRet)
	If Not IsObject(objLogFile) Then
		Set objLogFile = objFSO.OpenTextFile(scriptFolder & "\logfile.log", ForAppending, True)
	End If

	If sRet = "" Then
		objLogFile.WriteLine(Time & ": General Update ( """ & stepName & """)")
	ElseIf sRet = "begin" Then
		objLogFile.WriteLine(Time & ": """ & stepName & """ begun.")
		
		promptLoc = scriptFolder & "\prompt.exe"
		If objFSO.FileExists(promptLoc) Then
			sCmd = scriptFolder & "\prompt.exe ""[" & stepName & "] is processing"" 10"
			sRet = objShell.Run(sCmd, 2, False)
		End If

	Else
		objLogFile.WriteLine(Time & ": """ & stepName & """ ran and returned: " & sRet)
	End If
End Sub

Function IsRunning(procName)

	Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
	Set colProcesses = objWMIService.ExecQuery("Select * From Win32_Process " & _
	"Where Name = '" & procName & "'")

	If colProcesses.Count > 0 Then
		IsRunning = True
	Else
		IsRunning = False
	End If

End Function

Sub jobFinished()
	'Disable AutoLogon Entries\
	logHelper "Disable AutoLogon Entries", "begin"
	objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon", "0", "REG_SZ"
	objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultUserName", "", "REG_SZ"
	objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultDomainName", "", "REG_SZ"
	objShell.RegDelete "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultPassword"
	objShell.RegWrite "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoLogonCount", &H00000000, "REG_DWORD"
	logHelper "Disable AutoLogon Entries", err.Number

	'Delete postmdt startup entry
	'postmdtLoc = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\postmdt.lnk"
	'If objFSO.FileExists(postmdtLoc) Then
	'	logHelper "Delete postmdt shortcut from startup", "begin"
	'	'sCmd = "cmd.exe /c del /F ""C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\postmdt.lnk"""
	'	'sRet = objShell.Run(sCmd, 0, True)
	'	objFSO.DeleteFile "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\postmdt.lnk", True
	'	logHelper "Delete postmdt shortcut from startup", err.Number
	'End If

	'Initialize SEP
	'logHelper "Initialize SEP BEFORE NetMotion", "begin"
	'sCmd = scriptFolder & "\sep\sylinkdrop.exe -silent """ & scriptFolder & "\Tablets_sylink.xml"""
	'sRet = objShell.Run(sCmd, 1, True)
	'logHelper "Initialize SEP BEFORE NetMotion", sRet

	'If objFSO.FileExists("C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\smc.exe") Then
	'	logHelper "Execute -UpdateConfig BEFORE NetMotion", "begin"
	'	sCmd = """C:\Program Files (x86)\Symantec\Symantec Endpoint Protection\smc.exe"" -updateconfig"
	'	sRet = objShell.Run(sCmd, 1, True)
	'	logHelper "Execute -UpdateConfig BEFORE NetMotion", sRet
	'Else
	'	logHelper "SMC.exe not found, not updating config", ""
	'End If

	'Install NetMotion client
	logHelper "Install NetMotion client", "begin"
	objShell.CurrentDirectory = scriptFolder & "\netmotion"
	sCmd = "cmd /c silent.bat"
	sRet = objShell.Run(sCmd, 0, True)
	logHelper "Install NetMotion client", sRet

	'Copy start menu shortcuts
	logHelper "Rebuilding startmenu", "begin"
	objShell.CurrentDirectory = scriptFolder & "\startmenu"
	sCmd = "cmd /c silent.bat"
	sRet = objShell.Run(sCmd, 0, True)
	logHelper "Rebuilding startmenu", sRet

	'Run hopsdetect1_utilfiletxt Script
	logHelper "hopsdetect1_utilfiletxt Script", "begin"
	objShell.CurrentDirectory = scriptFolder & "\hopsdetect"
	sCmd = "cmd /c hopsdetect1_utilfiletxt.cmd"
	sRet = objShell.Run(sCmd, 0, True)
	logHelper "hopsdetect1_utilfiletxt Script", sRet

	'Copy Netlog script to Startup
	netlogLoc = "C:\wutemp\Shortcuts\Netlog.lnk"
	If objFSO.FileExists(netlogLoc) Then
		logHelper "Copy netlog script", "begin"
		objFSO.CopyFile netlogLoc, "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\", True
		logHelper "Copy netlog script", err.Number
	End If
	
	'Copy other shortcuts to the Startup Folder
	'ie. pin icon setup, etc.
	startupLoc = scriptFolder & "\startup"
	If objFSO.FolderExists(startupLoc) Then
		logHelper "Copy other startup scripts", "begin"
		objFSO.CopyFile startupLoc & "\*.*", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\", True
		logHelper "Copy other startup scripts", err.Number
	End If
	
	'Write imageRevision to Version Document
	versionLoc = "c:\util\version.doc"
	If objFSO.FileExists(versionLoc) Then
		logHelper "Remove read only flag on " & versionLoc, "begin"
		sCmd = "attrib -R """ & versionLoc & """"
		sRet = objShell.Run(sCmd, 0, True)
		logHelper "Remove read only flag on " & versionLoc, sRet
		
		logHelper "Write version number to " & versionLoc, "begin"
		Set objversionFile = objFSO.OpenTextFile(versionLoc, ForWriting, True)
		sRet = objversionFile.WriteLine(versionNumber)
		logHelper "Write version number to " & versionLoc, sRet
	End If
	

	'Notify Tech that Script is complete.
	objShell.Popup "PostMDT Script is complete.", 20, "Encryption of drive has begun...", 64
	logHelper "Script is complete", ""

End Sub

Sub ReRunIfMSIWasRunning(sCmd, sRet)
	counter = 0
	Do While sRet = "1618"
		counter = counter + 1
		logHelper "Install failed due to MSI already running, pausing script and re-running install in 3 minutes. Try number " & counter, ""
		sRet = objShell.Run(sCmd, 0, True)
		If counter > 4 Then
			Exit Do
		End If
		WScript.Sleep 180000
	Loop
End Sub

Function CSI_IsAdmin()
  CSI_IsAdmin = False
  On Error Resume Next
  key = CreateObject("WScript.Shell").RegRead("HKEY_USERS\S-1-5-19\Environment\TEMP")
  If err.number = 0 Then CSI_IsAdmin = True
End Function
