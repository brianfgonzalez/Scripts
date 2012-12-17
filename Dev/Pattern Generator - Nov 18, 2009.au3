;---------------------------------------------------------------
; Title: Regular Expression Pattern Generator - Simple Patterns
; Author: Eddy Mison
; Remark: Not for advanced user
;-----------------------------
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=H:\SRE Pattern Generator.kxf
$main_gui = GUICreate("SRE Pattern Generator - Basic Pattern", 522, 403, 219, 127)
GUICtrlCreateGroup("Source", 8, 0, 505, 105)
$e_source = GUICtrlCreateEdit("", 16, 16, 489, 81)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Parameter", 8, 112, 505, 113)
GUICtrlCreateGroup("Begins With", 16, 128, 113, 89)
$c_begin = GUICtrlCreateCombo(" ", 24, 144, 97, 25,$CBS_DROPDOWNLIST)
GUICtrlSetData(-1,"Begin of line|Word Boundary|Custom...")
$cb_begin = GUICtrlCreateCheckbox("Include in match", 24, 192, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)
$i_begin = GUICtrlCreateInput("", 24, 168, 97, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Character Class", 136, 128, 153, 89)
$c_contain = GUICtrlCreateCombo("", 144, 144, 137, 25,$CBS_DROPDOWNLIST)
GUICtrlSetData(-1, "Any Character|Word Character|Numeric|White Space")
$r_greedy = GUICtrlCreateRadio("Greedy", 144, 192, 57, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
$r_lazy = GUICtrlCreateRadio("Lazy", 200, 192, 65, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Ends With", 392, 128, 113, 89)
$c_end = GUICtrlCreateCombo(" ", 400, 144, 97, 25,$CBS_DROPDOWNLIST)
GUICtrlSetData(-1,"End of line|Word Boundary|Custom...")
$cb_end = GUICtrlCreateCheckbox("Include in match", 400, 192, 97, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetState(-1, $GUI_DISABLE)
$i_end = GUICtrlCreateInput("", 400, 168, 97, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Repetition", 296, 128, 89, 89)
$c_rep = GUICtrlCreateCombo("0 or more", 304, 144, 73, 25,$CBS_DROPDOWNLIST)
GUICtrlSetData(-1, "1 or more|0 or 1|No Repeat")
$i_repeat = GUICtrlCreateInput("", 304, 168, 73, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Pattern", 8, 232, 505, 49)
$i_pattern = GUICtrlCreateInput("", 16, 248, 489, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlCreateGroup("Match Array (Flag 3)", 8, 288, 505, 105)
$l_match = GUICtrlCreateList("", 16, 304, 489, 84)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

;combo handles
$c_begin_handle = GUICtrlGetHandle($c_begin)
$c_contain_handle = GUICtrlGetHandle($c_contain)
$c_end_handle = GUICtrlGetHandle($c_end)
$c_rep_handle = GUICtrlGetHandle($c_rep)

; radio, checkbox handles
$cb_begin_handle = GUICtrlGetHandle($cb_begin)
$r_greedy_handle = GUICtrlGetHandle($r_greedy)
$r_lazy_handle = GUICtrlGetHandle($r_lazy)
$cb_end_handle = GUICtrlGetHandle($cb_end)

;input, edit handles
$e_source_handle = GUICtrlGetHandle($e_source)
$i_begin_handle = GUICtrlGetHandle($i_begin)
$i_end_handle = GUICtrlGetHandle($i_end)
$i_repeat_handle = GUICtrlGetHandle($i_repeat)
$i_pattern_handle = GUICtrlGetHandle($i_pattern)


While 1
	$msg = GUIGetMsg()
	Switch $msg
	Case $GUI_EVENT_CLOSE
		Exit
	EndSwitch
WEnd

Func makePattern()
	If GUICtrlRead($c_begin) = "Custom..." Then 
		GUICtrlSetState($i_begin, $GUI_ENABLE)
		GUICtrlSetState($cb_begin, $GUI_ENABLE)
	Else
		GUICtrlSetData($i_begin, "")
		GUICtrlSetState($cb_begin, $GUI_CHECKED)
		GUICtrlSetState($i_begin, $GUI_DISABLE)
		GUICtrlSetState($cb_begin, $GUI_DISABLE)
	EndIf
	If GUICtrlRead($c_end) = "Custom..." Then 
		GUICtrlSetState($i_end, $GUI_ENABLE)
		GUICtrlSetState($cb_end, $GUI_ENABLE)
	Else
		GUICtrlSetData($i_end, "")
		GUICtrlSetState($cb_end, $GUI_CHECKED)
		GUICtrlSetState($i_end, $GUI_DISABLE)
		GUICtrlSetState($cb_end, $GUI_DISABLE)
	EndIf
	$class = ""
	Switch GUICtrlRead($c_contain)
	Case "Any Character"
		$class = "."
	Case "Word Character"
		$class = "\w"
	Case "Numeric"
		$class = "\d"
	case "White Space"
		$class = "\s"
	EndSwitch
	
	If $class <> "" Then
		Switch GUICtrlRead($c_rep)
		Case "No Repeat"
			;
		Case "0 or more"
			$class &= "*"
		Case "1 or more"
			$class &= "+"
		Case "0 or 1"
			$class &= "?"
		EndSwitch
	EndIf
	
	If GUICtrlRead($r_lazy) = $GUI_CHECKED Then $class &= "?"

	$begin = ""
	Switch GUICtrlRead($c_begin)
	Case "", " "
		;
	Case "Begin of line"
		$begin = "^"
	Case "Word Boundary"
		$begin = "\b"
	Case "Custom..."
		GUICtrlSetState($i_begin, $GUI_ENABLE)
		$begin = escapeChar(GUICtrlRead($i_begin))
	EndSwitch
	If GUICtrlRead($cb_begin) = $GUI_UNCHECKED Then $begin = "(?<="&$begin&")"
	
	$end = ""
	Switch GUICtrlRead($c_end)
	Case "", " "
		;
	Case "End of line"
		$end = "$"
	Case "Word Boundary"
		$end = "\b"
	Case "Custom..."
		GUICtrlSetState($i_end, $GUI_ENABLE)
		$end =  escapeChar(GUICtrlRead($i_end))
	EndSwitch
	If GUICtrlRead($cb_end) = $GUI_UNCHECKED Then $end = "(?="&$end&")"

	GUICtrlSetData($i_pattern, $begin&$class&$end)
	getMatch()
EndFunc

Func escapeChar($char)
	If $char = "" Then Return ""
	If $char = " " Then Return "\s"
	If StringLen($char) = 1 Then
		If StringInStr("\^$.[|()?*+{",$char) Then
			Return "\"&$char
		Else
			Return $char
		EndIf
	Else
		Return "\Q"&$char&"\E"
	EndIf
EndFunc
Func getMatch()
	GUICtrlSetData($l_match,"")
	$source = GUICtrlRead($e_source)
	$pattern = GUICtrlRead($i_pattern)
	$match = StringRegExp($source,$pattern,3)
	If Not IsArray($match) Then Return
	For $i = 0 To UBound($match)-1
		GUICtrlSetData($l_match, "["&$i&"]"&" "&$match[$i])
	Next
EndFunc

Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)
	#forceref $hWnd, $iMsg
	Local $hWndFrom, $iIDFrom, $iCode, $hWndCombo
	$hWndFrom = $ilParam
	$iIDFrom = BitAND($iwParam, 0xFFFF) ; Low Word
	$iCode = BitShift($iwParam, 16) ; Hi Word
	
	
	Switch $hWndFrom
	Case $c_begin_handle, $c_contain_handle, $c_end_handle, $c_rep_handle, $cb_begin_handle, $r_greedy_handle, $r_lazy_handle, $cb_end_handle,  $i_begin_handle, $i_end_handle, $i_repeat_handle
		Switch $iCode
			Case $CBN_SELENDOK, $BN_CLICKED, $EN_CHANGE
			makePattern()
		EndSwitch
	Case $e_source_handle, $i_pattern_handle
		Switch $iCode
		Case $EN_CHANGE
			getMatch()
		EndSwitch
	EndSwitch
EndFunc