If Wscript.Arguments.Count = 0 Then
	aComputers = Array(".")
Else
	Dim aComputers()
	For i = 0 to Wscript.Arguments.Count - 1
		Redim Preserve aComputers(i)
		aComputers(i) = Wscript.Arguments(i)
	Next
End If
For Each sComputer in aComputers
	Wscript.echo GetTPMInfo(sComputer)
Next

Function GetTPMInfo(sComputer)
	On Error Resume Next
	Set oWMITPM = GetObject("winmgmts:{impersonationLevel=impersonate,authenticationLevel=pktPrivacy}!\\" & sComputer & "\root\cimv2\Security\MicrosoftTpm")
	If sComputer = "." Then sComputer = "LocalHost"
	If Err Then
		GetTPMInfo = sComputer & ": Microsoft TPM Connection failed."
		Exit Function
	End If
	Set colTPM = oWMITPM.InstancesOf("Win32_Tpm")
	If colTPM.Count = 0 Then
		GetTPMInfo = sComputer & ": No Win32_Tpm instances found."
		Exit Function
	End If
	Set oTPM = oWMITPM.Get("Win32_Tpm=@")
	If Err Then
		GetTPMInfo = sComputer & ": Win32_Tpm instance connection failed."
		Exit Function
	End If
	If Left(CStr(oTPM.SpecVersion),3) = 1.2 Then sSpecVersion = "TPM Version: 1.2" Else sSpecVersion = "TPM Version: " & oTPM.SpecVersion
	ReturnCode = oTPM.IsEnabled(bIsEnabled)
	If ReturnCode <> 0 Then
		sIsEnabled = "IsEnabled: " & bIsEnabled & " (ERROR 0x" & Hex(ReturnCode) & ")"
	ElseIf bIsEnabled Then
		sIsEnabled = "Enabled"
	Else
		sIsEnabled = "Disabled"
	End If
	ReturnCode = oTPM.IsActivated(bIsActivated)
	If ReturnCode <> 0 Then
		sIsActivated = "IsActivated: " & bIsActivated & " (ERROR 0x" & Hex(ReturnCode) & ")"
	ElseIf bIsActivated Then
		sIsActivated = "Activated"
	Else
		sIsActivated = "Deactivated"
	End If
	ReturnCode = oTPM.IsOwned(bIsOwned)
	If ReturnCode <> 0 Then
		sIsOwned = "IsOwned: " & bIsOwned & " (ERROR 0x" & Hex(ReturnCode) & ")"
	ElseIf bIsOwned Then
		sIsOwned = "Owned"
	Else
		sIsOwned = "Unowned"
	End If
	GetTPMInfo = sComputer & ": " & sSpecVersion & " (" & sIsEnabled & ", " & sIsActivated & ", " & sIsOwned & ")"
End Function