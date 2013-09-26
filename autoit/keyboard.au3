#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <ButtonConstants.au3>

$WS_EX_NOACTIVATE = 0x08000000
$MA_NOACTIVATE = 3
$MA_NOACTIVATEANDEAT = 4

HotKeySet("{ESC}", "On_Exit")

Global $aKeys[48] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", _
                     "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "[", "]", _
                     "A", "S", "D", "F", "G", "H", "J", "K", "L", ";", "'", '"', _
                     "Z", "X", "C", "V", "B", "N", "M", ",", ".", "/", "spc", "enter"]

; Create "keyboard" GUI
$hGUI = GUICreate("Test", 360, 120, 500, 100, $WS_POPUPWINDOW, BitOR($WS_EX_TOOLWINDOW, $WS_EX_TOPMOST, $WS_EX_NOACTIVATE))

$dummy1 = GUICtrlCreateDummy()
$iCount = 0
For $j = 0 To 3
    For $i = 0 To 11
        GUICtrlCreateButton("", $i * 30, $j * 30, 30, 30)
        GUICtrlSetData(-1, $aKeys[$iCount])
        $iCount += 1
;~         GUICtrlSetFont(-1, 10)
;~         GUICtrlSetBkColor(-1, 30000 + 2000 * ($i + 1) + 2000 * ($j + 1))
    Next
Next
$dummy2 = GUICtrlCreateDummy()
GUISetState()

GUIRegisterMsg($WM_MOUSEACTIVATE, 'WM_EVENTS')

Run("notepad.exe")

While 1
    $msg = GUIGetMsg()
    Switch $msg
        Case $GUI_EVENT_CLOSE
            Exit
        Case $dummy1 To $dummy2
            Local $sText = ControlGetText($hGUI, "", $msg)
            ; Write key
            If $sText = "spc" Then
                Send("{SPACE}")
            ElseIf $sText = "enter" Then
                Send("{ENTER}")
            Else
                Send($sText)
            EndIf
    EndSwitch
WEnd

Func WM_EVENTS($hWndGUI, $MsgID, $WParam, $LParam)
    Switch $hWndGUI
        Case $hGUI
            Switch $MsgID
                Case $WM_MOUSEACTIVATE
                    ; Check mouse position
                    Local $aMouse_Pos = GUIGetCursorInfo($hGUI)
                    If $aMouse_Pos[4] <> 0 Then
                        Local $word = _WinAPI_MakeLong($aMouse_Pos[4], $BN_CLICKED)
                        _SendMessage($hGUI, $WM_COMMAND, $word, GUICtrlGetHandle($aMouse_Pos[4]))
                    EndIf
                    Return $MA_NOACTIVATEANDEAT
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc

Func On_Exit()
    Exit
EndFunc