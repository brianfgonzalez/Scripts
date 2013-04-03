; Autor: Luigi(Detefon)
; 14/10/2012

#include <guiconstants.au3>
#include <StaticConstants.au3>
; Variable's name
Global $valueCurrent = 120
Global $valueMax = 200
Global $x = 20
Global $y = 20
Global $width = 250
Global $height = 15
Global $text = "HP"
; The GUI must have the option $WS_EX_COMPOSITED (0x02000000)
GUICreate("Luigi's HP Bar", 400, 400, -1, -1, Default, 0x02000000)
$newBar= _barCreate($x, $y, $width, $height, $valueCurrent, $valueMax, $text)
GUISetState()

While 1
If GUIGetMsg() = $GUI_EVENT_CLOSE Then Exit
$valueCurrent += 5
If $valueCurrent > $valueMax Then $valueCurrent = 0
Sleep(50)
_barUpdate($newBar, $valueCurrent)
WEnd


Func _barCreate($_x, $_y, $_width, $_height, $_valueCurrent, $_valueMax, $_text)
Local $_hex[16] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, "A", "B", "C", "D", "E", "F"], $contador = 0
Local $_var[3]
For $x = 0 To 2
Do
$_var[$x] = $_hex[Random(0, 15, 1)] & $_hex[Random(0, 15, 1)] & $_hex[Random(0, 15, 1)] & $_hex[Random(0, 15, 1)] & $_hex[Random(0, 15, 1)] & $_hex[Random(0, 15, 1)]
$contador += 1
If $contador > 256 Then Return SetError(-1, 1, 1)
Until Not IsDeclared($_var[$x])
Next
Assign($_var[1], GUICtrlCreateGraphic($_x - 1, $_y - 1, $_width + 2, $_height + 2), 2)
Local $alt[3]
$alt[0] = Int($_height / 3)
$alt[2] = Int($_height / 3)
$alt[1] = $_height - $alt[0] - $alt[2]
GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0x00ff00, 0x0000ff)
GUICtrlSetBkColor(-1, 0xD6D4D2)
GUICtrlSetColor(-1, 0x897659)
Local $percent = Int(($_valueCurrent / $_valueMax) * 100)
Local $bar_a = Int($_width * ($percent / 100))
Local $bar_b = $_width - $bar_a
GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0xDE8D69, 0xDE8D69)
GUICtrlSetGraphic(-1, $GUI_GR_RECT, 1, 1, $bar_a, $alt[0])
GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0xBE371C, 0xBE371C)
GUICtrlSetGraphic(-1, $GUI_GR_RECT, 1, 1 + $alt[0], $bar_a, $alt[1])
GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0x540404, 0x540404)
GUICtrlSetGraphic(-1, $GUI_GR_RECT, 1, 1 + $alt[0] + $alt[1], $bar_a, $alt[2])
GUICtrlSetGraphic(-1, $GUI_GR_COLOR, 0xD6D4D2, 0xD6D4D2)
GUICtrlSetGraphic(-1, $GUI_GR_RECT, 1 + $bar_a, 1, $bar_b, $_height)

$_text1 = GUICtrlCreateLabel($_text, $_x + 1, $_y, Default, $_height, 0x0200)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, 9, 900, 0, "Lucida Console", 5)
GUICtrlSetColor(-1, 0xffffff)
Assign($_var[2], GUICtrlCreateLabel($_valueCurrent & "/" & $_valueMax, ($_width - 100 / 2) / 2, $_y + 2, 100, 13, 0x0200 + 0x01), 2)
GUICtrlSetBkColor(-1, $GUI_BKCOLOR_TRANSPARENT)
GUICtrlSetFont(-1, $_height / 2, 900, 0, "Lucida Console", 5)
GUICtrlSetColor(-1, 0xffffff)
; $_x, $_y, $_width, $_height, $_valueCurrent, $_valueMax, $_text
Assign($_var[0], $_var[1] & "," & $_var[2] & "," & $_x & "," & $_y & "," & $_width & "," & $_height & "," & $_valueCurrent & "," & $_valueMax, 2)
Return $_var[0]
EndFunc ;==>_barCreate

Func _barUpdate($control, $value)
$control = Eval($control)
Local $data = StringSplit($control, ",")
Local $alt[3]
$alt[0] = Int($data[6] / 3)
$alt[2] = Int($data[6] / 3)
$alt[1] = $data[6] - $alt[0] - $alt[2]

Local $percent = Int(($value / $data[8]) * 100)
Local $bar_a = Int($data[5] * ($percent / 100))
Local $bar_b = $data[5] - $bar_a

GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_COLOR, 0xDE8D69, 0xDE8D69)
GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_RECT, 1, 1, $bar_a, $alt[0])

GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_COLOR, 0xBE371C, 0xBE371C)
GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_RECT, 1, 1 + $alt[0], $bar_a, $alt[1])

GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_COLOR, 0x540404, 0x540404)
GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_RECT, 1, 1 + $alt[0] + $alt[1], $bar_a, $alt[2])
GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_COLOR, 0xD6D4D2, 0xD6D4D2)
GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_RECT, 1 + $bar_a, 1, $bar_b, $data[6])
GUICtrlSetGraphic(Eval($data[1]), $GUI_GR_REFRESH)
GUICtrlSetData(Eval($data[2]), $value & "/" & $data[8])
EndFunc ;==>_barUpdate

; Webgrafia
; http://www.autoitscript.com/forum/topic/83454-pong/
; http://www.autoitscript.com/forum/topic/53016-cool-looking-progress-bar-help-me-remove-flickering/