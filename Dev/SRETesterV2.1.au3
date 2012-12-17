#include <GUIConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <IE.au3>
#include <Date.au3>
; Thanks to w0uter for the original GUI layout.





Global $CurrentInput, $SREMode = 0, $SREFlag = 0, $FileSaved = False
Global $aTime[5]

$MainGUI = GUICreate("String Regular Expression Tester", 632, 628)
$HTabMain = GUICtrlCreateTab(5, 15, 620, 200)
$hTab1 = GUICtrlCreateTabItem("Test text")
$hInput1 = GUICtrlCreateEdit("",10,42, 608, 166)
GUICtrlSetLimit(-1, 1000000)
$CurrentInput = $hInput1
$hTab2 = GUICtrlCreateTabItem("Load file to test")
$LoadFileButton = GUICtrlCreateButton("Open", 15, 45, 60, 20)
$FileLoadedInput = GUICtrlCreateInput("", 90, 45, 528, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$hInput2 = GUICtrlCreateEdit("",10,72, 608, 136)
$hTab3 = GUICtrlCreateTabItem("Get website text/HTML")
$WebTextButton = GUICtrlCreateButton("Text", 15, 45, 60, 20)
$WebHTMLButton = GUICtrlCreateButton("HTML", 85, 45, 60, 20)
$WebADDRInput = GUICtrlCreateInput("FULL ADDR HERE", 160, 45, 458, 20)
$hInput3 = GUICtrlCreateEdit("",10,72, 608, 136)
$hTab4 = GUICtrlCreateTabItem("Notes")
$LoadFileButton_Notes = GUICtrlCreateButton("Open", 15, 45, 60, 20)
$SaveFileButton_Notes = GUICtrlCreateButton("Save", 90, 45, 60, 20)
$FileLoadedInput_Notes = GUICtrlCreateInput("", 170, 45, 448, 20)
GUICtrlSetState(-1, $GUI_DISABLE)
$hInput_Notes = GUICtrlCreateEdit(";;; Personal notepad to store anything you want in ;;;" & @CRLF,10,72, 608, 136)
$hTab5 = GUICtrlCreateTabItem("AutoIt")
$LoadFileButton_AutoIt = GUICtrlCreateButton("Open file", 15, 45, 60, 20)
$SaveFileButton_AutoIt = GUICtrlCreateButton("Save file", 90, 45, 60, 20)
$OpenInScite_AutoIt = GUICtrlCreateButton("SciTE", 165, 45, 60, 20)
$RunButton_AutoIt = GUICtrlCreateButton("Run Script", 240, 45, 60, 20)
$RegExButton_AutoIt = GUICtrlCreateButton("Generate RegEx Code", 315, 45, 120, 20)
$hInput_AutoIt = GUICtrlCreateEdit("; Open, edit or run scripts from here. Default save Location is in ScriptDir\AutoItCode.au3" & @CRLF,10,72, 608, 136)
GUICtrlCreateTabItem("") ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GUICtrlCreateGroup("Pattern", 5, 217, 620, 67)
$HSRECombo = GUICtrlCreateInput("(.*)", 84, 235, 527, 32)
GUICtrlSetFont(-1, 14, 400, 0, "MS Reference Sans Serif")
GUICtrlSendMsg(-1, $CB_SETEDITSEL, 0, 0)
$ButtonTest = GUICtrlCreateButton("Test", 18, 237, 55, 27, 0)
$HSRERCombo = GUICtrlCreateInput("(.*)", 84, 235, 367, 32)
GUICtrlSetFont(-1, 14, 400, 0, "MS Reference Sans Serif")
GUICtrlSendMsg(-1, $CB_SETEDITSEL, 0, 0)
GUICtrlSetState(-1, $GUI_HIDE)
$HSRERReplace = GUICtrlCreateInput("", 455, 235, 100, 32)
GUICtrlSetFont(-1, 14, 400, 0, "MS Reference Sans Serif")
GUICtrlSendMsg(-1, $CB_SETEDITSEL, 0, 0)
GUICtrlSetState(-1, $GUI_HIDE)
$HSRERCount = GUICtrlCreateInput("0", 565, 235, 50, 32)
GUICtrlSetFont(-1, 14, 400, 0, "MS Reference Sans Serif")
GUICtrlSendMsg(-1, $CB_SETEDITSEL, 0, 0)
GUICtrlSetState(-1, $GUI_HIDE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Type", 5, 292, 125, 73)
$HRadioSRE = GUICtrlCreateRadio("StringRegEx", 10, 308, 82, 23)
GUICtrlSetState(-1, $GUI_CHECKED)
$HRadioSRER = GUICtrlCreateRadio("RegExpReplace", 10, 331, 96, 23)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Flag", 5, 370, 125, 138)
$HRadioF0 = GUICtrlCreateRadio("0: True/False", 10, 388, 82, 23)
GUICtrlSetTip(-1, "Returns 1 (matched) or 0 (no match).")
GUICtrlSetState(-1, $GUI_CHECKED)
$HRadioF1 = GUICtrlCreateRadio("1: Array of matches", 10, 411, 112, 23)
GUICtrlSetTip(-1, "Return array of matches.")
$HRadioF2 = GUICtrlCreateRadio("2: Array (Perl / PHP)", 10, 433, 112, 23)
GUICtrlSetTip(-1, "Return array of matches including the full match (Perl / PHP style)..")
$HRadioF3 = GUICtrlCreateRadio("3: Global matches", 10, 455, 112, 23)
GUICtrlSetTip(-1, "Return array of global matches.")
$HRadioF4 = GUICtrlCreateRadio("4: A/A (Perl / PHP)", 10, 477, 112, 23)
GUICtrlSetTip(-1, "Return an array of arrays containing global matches including the full match (Perl / PHP style).")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$HOutput = GUICtrlCreateEdit("", 135, 284, 490, 339)
$Group4 = GUICtrlCreateGroup("Return Values", 5, 514, 125, 68)
$Label1 = GUICtrlCreateLabel("@Error", 13, 532, 37, 17)
GUICtrlSetColor(-1, 0x3399FF)
$Label2 = GUICtrlCreateLabel("@Extended", 58, 532, 60, 17)
GUICtrlSetColor(-1, 0x3399FF)
$HError = GUICtrlCreateInput("", 13, 552, 37, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$HExtended = GUICtrlCreateInput("", 62, 552, 52, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$ButtonHelp = GUICtrlCreateButton("Help!", 10, 591, 112, 30, 0)
GUISetState(@SW_SHOW)


While 1
	Sleep(20)
	If $FileSaved = True And WinActive($MainGUI) = 1 Then
		$aTime2 = FileGetTime(@ScriptDir & '\AutoItCode.au3')
		$iDateCalc = _DateDiff('s', $aTime[0] & "/" & $aTime[1] & "/" & $aTime[2] & " " & $aTime[3] & ":" & $aTime[4] & ":" & $aTime[5], $aTime2[0] & "/" & $aTime2[1] & "/" & $aTime2[2] & " " & $aTime2[3] & ":" & $aTime2[4] & ":" & $aTime2[5])
		If $iDateCalc >=1 Then 
			GUICtrlSetData($hInput_AutoIt, FileRead(@ScriptDir & '\AutoItCode.au3'))
			$FileSaved = False
		Else
			$FileSaved = False
		EndIf
	EndIf
	
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
			
		Case $LoadFileButton
			$Address = FileOpenDialog("Open a file to test", @WorkingDir, "Text Related (*.*)")
			If @error <> 1 Then GUICtrlSetData($hInput2, FileRead($Address))
			GUICtrlSetData($FileLoadedInput, $Address)
		Case $LoadFileButton_Notes
			$Address = FileOpenDialog("Open a file to test", @WorkingDir, "Text Related (*.*)")
			If @error <> 1 Then GUICtrlSetData($hInput_Notes, FileRead($Address))
			GUICtrlSetData($FileLoadedInput_Notes, $Address)
		Case $SaveFileButton_Notes
			$Address = FileSaveDialog("Save Notes", @WorkingDir, "Text (*.txt)", 16)
			If StringRight($Address, 4) <> ".txt" Then $Address &= ".txt"
			FileDelete($Address)
			FileWrite($Address, GUICtrlRead($hInput_Notes))
		Case $LoadFileButton_AutoIt
			$Address = FileOpenDialog("Open a file to test", @WorkingDir, "Text Related (*.*)")
			If @error <> 1 Then GUICtrlSetData($hInput_AutoIt, FileRead($Address))
		Case $SaveFileButton_AutoIt
			$Address = FileSaveDialog("Save Script", @WorkingDir, "Au3 (*.au3)", 16)
			If StringRight($Address, 4) <> ".au3" Then $Address &= ".au3"
			FileDelete($Address)
			FileWrite($Address, GUICtrlRead($hInput_AutoIt))
		Case $OpenInScite_AutoIt
			FileDelete(@ScriptDir & '\AutoItCode.au3')
			FileWrite(@ScriptDir & '\AutoItCode.au3', GUICtrlRead($hInput_AutoIt))
			ShellExecute(@ScriptDir & '\AutoItCode.au3', "", "", "Open")
			$aTime = FileGetTime(@ScriptDir & '\AutoItCode.au3')
			$FileSaved = True
			Sleep(1000)
		Case $RunButton_AutoIt
			FileDelete(@ScriptDir & '\AutoItCode.au3')
			FileWrite(@ScriptDir & '\AutoItCode.au3', GUICtrlRead($hInput_AutoIt))
			ShellExecute(@ScriptDir & '\AutoItCode.au3', "", "", "Run")
		Case $RegExButton_AutoIt
			If $SREMode = 0 Then
				$sPattern = GUICtrlRead($HSRECombo)
				GUICtrlSetData($HOutput, "StringRegExp($Value, "  & '"' & $sPattern & '"' & ", " &  $SREFlag & ")" )
			Else
				$sPattern = GUICtrlRead($HSRERCombo)
				$sReplace = GUICtrlRead($HSRERReplace)
				$iCount = GUICtrlRead($HSRERCount)
				GUICtrlSetData($HOutput, "StringRegExpReplace($Value, "  & '"' & $sPattern & '"' & ", " & '"' & $sReplace & '"' & ", " & $iCount & ")" )
			EndIf
			
			
		Case $HTabMain
			If GUICtrlRead($HTabMain) = 0 Then
				$CurrentInput = $hInput1
			ElseIf GUICtrlRead($HTabMain) = 1 Then
				$CurrentInput = $hInput2
			ElseIf GUICtrlRead($HTabMain) = 2 Then
				$CurrentInput = $hInput3
				GUICtrlSetState($WebADDRInput, $GUI_FOCUS)
				GUICtrlSendMsg($WebADDRInput, $EM_SETSEL, 0 , 1000)
			EndIf
			
		Case $HRadioSRE
			$SREMode = 0
			GUICtrlSetState($HRadioF0, $GUI_ENABLE)
			GUICtrlSetState($HRadioF1, $GUI_ENABLE)
			GUICtrlSetState($HRadioF2, $GUI_ENABLE)
			GUICtrlSetState($HRadioF3, $GUI_ENABLE)
			GUICtrlSetState($HRadioF4, $GUI_ENABLE)
			GUICtrlSetState($HSRERCombo, $GUI_HIDE)
			GUICtrlSetState($HSRERReplace, $GUI_HIDE)
			GUICtrlSetState($HSRECombo, $GUI_SHOW)
			GUICtrlSetState($HSRERCount, $GUI_HIDE)
		Case $HRadioSRER
			$SREMode = 1
			GUICtrlSetState($HRadioF0, $GUI_DISABLE)
			GUICtrlSetState($HRadioF1, $GUI_DISABLE)
			GUICtrlSetState($HRadioF2, $GUI_DISABLE)
			GUICtrlSetState($HRadioF3, $GUI_DISABLE)
			GUICtrlSetState($HRadioF4, $GUI_DISABLE)
			GUICtrlSetState($HSRECombo, $GUI_HIDE)
			GUICtrlSetState($HSRERCombo, $GUI_SHOW)
			GUICtrlSetState($HSRERReplace, $GUI_SHOW)
			GUICtrlSetState($HSRERCount, $GUI_SHOW)
		Case $HRadioF0
			$SREFlag = 0
		Case $HRadioF1
			$SREFlag = 1
		Case $HRadioF2
			$SREFlag = 2
		Case $HRadioF3
			$SREFlag = 3
		Case $HRadioF4
			$SREFlag = 4	
		Case $ButtonTest
			SRE()
		Case $ButtonHelp
			$helppath = StringLeft(@AutoItExe, StringInStr(@AutoItExe, "\", 0, -1))
			Run($helppath & "Autoit3Help.exe StringRegExp")
			If @error = 1 Then MsgBox(0, "Error", "Cannot find help file")
		Case $WebTextButton
			_IELoadWaitTimeout(30000)
			GUICtrlSetData($hInput3, "Please wait...")
			$oIE = _IECreate(GUICtrlRead($WebADDRInput), 0, 0)
			If @error = 6 Then 
				GUICtrlSetData($hInput3, "Load Timeout")
			Else
				GUICtrlSetData($hInput3, _IEBodyReadText($oIE))
			EndIf
			_IEQuit($oIE)
		Case $WebHTMLButton
			_IELoadWaitTimeout(30000)
			GUICtrlSetData($hInput3, "Please wait...")
			$oIE = _IECreate(GUICtrlRead($WebADDRInput), 0, 0)
			If @error = 6 Then 
				GUICtrlSetData($hInput3, "Load Timeout")
			Else
				GUICtrlSetData($hInput3, _IEBodyReadHTML($oIE))
			EndIf
			_IEQuit($oIE)
			
	EndSwitch
WEnd


Func SRE()


	If $SREMode = 0 Then
		$sText = GUICtrlRead($CurrentInput)
		$sPattern = GUICtrlRead($HSRECombo)
		$Regex = StringRegExp($sText, $sPattern, $SREFlag)
		$iError = @error
		$iExt = @extended		
		GUICtrlSetData($HError, $iError)
		GUICtrlSetData($HExtended, $iExt)
		
		
		
		If $SREFlag <=3  Then
			$RegExSize = UBound($Regex)
			If @error = 1 Then
				GUICtrlSetData($HOutput, $Regex)
			Else
				
				$OutputString = ""
				For $I = 0 To $RegExSize - 1
					$OutputString &= "[" & $I & "] = " & $Regex[$I] & @CRLF
				Next
				
				GUICtrlSetData($HOutput, $OutputString)
			EndIf
		
		Else
			$OutputString = ""
			For $I = 0 to UBound($Regex) - 1
			$match = $Regex[$i]
				for $J = 0 to UBound($match) - 1
					$OutputString &= "[" & $I & "," & $J & "] = " & $match[$j] & @CRLF 
				Next
			Next
			GUICtrlSetData($HOutput, $OutputString)
			
		EndIf
		
		If $iError = 2 Then 
			GUICtrlSetData($HOutput, "Error in pattern. Character: " & $iExt - 2 )
			GUICtrlSetState($HSRECombo, $GUI_FOCUS)
			GUICtrlSendMsg($HSRECombo, $EM_SETSEL, $iExt - 2 , $iExt - 1)
		EndIf
		
		
	Elseif $SREMode = 1 Then
		
		
		$sText = GUICtrlRead($CurrentInput)
		$sPattern = GUICtrlRead($HSRERCombo)
		$sReplace = GUICtrlRead($HSRERReplace)
		$iCount = GUICtrlRead($HSRERCount)
		$sRegExR = StringRegExpReplace($sText, $sPattern, $sReplace, $iCount)
		$iError = @error
		$iExt = @extended
		

		GUICtrlSetData($HError, $iError)
		GUICtrlSetData($HExtended, $iExt)
		GUICtrlSetData($HOutput, $sRegExR)
		
		If $iError = 2 Then 
			GUICtrlSetData($HOutput, "Error in pattern. Character: " & $iExt - 2 )
			GUICtrlSetState($HSRERCombo, $GUI_FOCUS)
			GUICtrlSendMsg($HSRERCombo, $EM_SETSEL, $iExt - 2 , $iExt - 1)
		EndIf
		
		
	EndIf
	
	
EndFunc
