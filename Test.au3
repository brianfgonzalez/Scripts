#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=test.Exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

If $cmdLine[0] > 0 Then
	For $i = 1 To $cmdLine[0]
		;MsgBox(0, "", "Full Argument: " & $cmdLine[$i])
		If StringInStr($cmdLine[$i], "/?") Or _
			StringInStr($cmdLine[$i], "-?") Or _
			StringInStr($cmdLine[$i], "?") Or _
			StringInStr($cmdLine[$i], "help") Then

			MsgBox(64, "Help information", "use ""/logPath="" to re-route log file" & @CRLF & _
				"use ""/killBDD=1"" to force OCB to kill BDD upon completion")
			Exit
		EndIf

		If StringInStr($cmdLine[$i], "/logPath") Then
			$splitArg = StringSplit($cmdLine[$i], "=")
			If $splitArg[0] > 1 Then
				If StringRight($splitArg[2],5)=".log""" Or _
				StringRight($splitArg[2],4)=".log" Or _
				StringRight($splitArg[2],5)=".txt""" Or _
				StringRight($splitArg[2],4)=".txt" Then
					$sLogFile = FileOpen($splitArg[2], 1)
					If $sLogFile = -1 Then
						MsgBox(16, "logPath error", "Unable to access/create log file (" & $splitArg[2] & ").")
						Exit
					EndIf
				Else
					PromptError("logPath", $splitArg[2])
				EndIf
		Else
				PromptError("logPath")
			EndIf
		EndIf
	Next
Else
	$sBDDKill = "False"
EndIf

Func PromptError($error, $info="Not Specified")
	Switch $error
		Case "logPath"
			MsgBox(16, "Error in logPath argument", "Syntex error in logPath,  please include full path to logfile (i.e. /logPath:""C:\MyLogs\MyLog.log"")" & @CRLF & "Specified logPath: " & $info)
			Exit
	EndSwitch
EndFunc