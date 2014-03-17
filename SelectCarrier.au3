#cs ------------------------------------------------------------------------------
 AutoIt Version:	3.3.8.1
 Author:			Brian Gonzalez
 Built:				3/6/2014
 Script Function:
	- Simple GUI to allow someone to select a carrier for use with Gobi 5000 modem
#ce ------------------------------------------------------------------------------
#include <GUIConstantsEx.au3>
$GUI = GUICreate("Select Carrier",400 ,400 ,100 ,100)
GUICtrlCreateLabel("Select your Desired Carrier?", 10, 10, 380, 100, 1)
$verizon = GUICtrlCreateRadio("Verizon", 10, 110, 380, 20)
$att = GUICtrlCreateRadio("AT&T", 10, 130, 380, 20)
$sprint = GUICtrlCreateRadio("Sprint", 10, 150, 380, 20)
$OKButton = GUICtrlCreateButton("OK", 120, 350, 40)
$CancelButton = GUICtrlCreateButton("Cancel", 200, 350, 40)
GUICtrlSetState($att, $GUI_CHECKED)
_CenterGUI($GUI, "Select Carrier")
GUISetState(@SW_SHOWNORMAL)

; Run the GUI until the dialog is closed
While 1
	$msg = GUIGetMsg()
	Select
        Case $msg = $GUI_EVENT_CLOSE
            ExitLoop
		Case $msg = $OKButton
			If GUICtrlRead($verizon) = $GUI_CHECKED Then
				MsgBox(0, "", "Verizon was Specified")
			ElseIf GUICtrlRead($att) = $GUI_CHECKED Then
				MsgBox(0, "", "AT&T was Specified")
			ElseIf GUICtrlRead($sprint) = $GUI_CHECKED Then
				MsgBox(0, "", "Sprint was Specified")
			EndIf
			ExitLoop
		Case $msg = $CancelButton
			MsgBox(0, "", "Cancel was hit")
			ExitLoop
	EndSelect
WEnd

Func _CenterGUI(Const $win, Const $txt)
    Local Const $size = WinGetClientSize($win, $txt)
    Local Const $y = (@DesktopHeight / 2) - ($size[1] / 2)
    Local Const $x = (@DesktopWidth / 2) - ($size[0] / 2)
    Return WinMove($win, $txt, $x, $y)
EndFunc  ;==>_Middle