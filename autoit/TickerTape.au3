#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>

#include "Marquee.au3"

Global $aMarquee_Coords[4] = [0, 0, @DesktopWidth, 60]
Global $fMarquee_Pos = "top", $hGUI = 0

; Create an array to hold the marquee indices
Global $aMarquee[8]

; Create GUI to display various marquee styles
GUICreate("Marquee Example 1", 320, 320)

; Initialise and create the marquees
$aMarquee[0] = _GUICtrlMarquee_Init()
_GUICtrlMarquee_Create($aMarquee[0], "Default Marquee Parameters", 10,  10, 300, 20)

$aMarquee[1] = _GUICtrlMarquee_Init()
_GUICtrlMarquee_SetScroll($aMarquee[1], Default, "alternate", "right", 7)
_GUICtrlMarquee_SetDisplay($aMarquee[1], 1, 0xFF0000, 0xFFFF00, 12, "times new roman")
_GUICtrlMarquee_Create($aMarquee[1], "Back And Forth", 10, 45, 300, 20)

$aMarquee[2] = _GUICtrlMarquee_Init()
_GUICtrlMarquee_SetScroll($aMarquee[2], 0, Default, "up", 1)
_GUICtrlMarquee_SetDisplay($aMarquee[2], 2, "green", Default, 18, "comic sans ms")
_GUICtrlMarquee_Create($aMarquee[2], "Up and Up...", 10, 80, 150, 30, "Vertical Scroll Up")

$aMarquee[3] = _GUICtrlMarquee_Init()
_GUICtrlMarquee_SetScroll($aMarquee[3], 0, Default, "down", 1)
_GUICtrlMarquee_SetDisplay($aMarquee[3], 2, "fuchsia", Default, 18, "comic sans ms")
_GUICtrlMarquee_Create($aMarquee[3], "Down We Go", 160, 80, 150, 30, "Vertical Scroll Down")

$aMarquee[4] = _GUICtrlMarquee_Init()
_GUICtrlMarquee_SetScroll($aMarquee[4], 0, Default, "right", Default, 120)
_GUICtrlMarquee_SetDisplay($aMarquee[4], 3, "red", "silver", 12, "arial")
_GUICtrlMarquee_Create($aMarquee[4], "And slowly to the right", 10, 120, 300, 26)

$aMarquee[5] = _GUICtrlMarquee_Init()
_GUICtrlMarquee_SetScroll($aMarquee[5], 1, "slide", Default, 2)
_GUICtrlMarquee_SetDisplay($aMarquee[5], 1, "blue", "cyan", 9, "courier new")
_GUICtrlMarquee_Create($aMarquee[5], " Just the once", 10, 160, 300, 17)

$aMarquee[6] = _GUICtrlMarquee_Init()
_GUICtrlMarquee_SetScroll($aMarquee[6])
_GUICtrlMarquee_SetDisplay($aMarquee[6])
_GUICtrlMarquee_Create($aMarquee[6], "Default Marquee Parameters", 10, 190, 300, 20, "Everything at default")

; Create buttons to demonstrate UDF functions
$cButton_1 = GUICtrlCreateButton("Change top text", 10, 220, 90, 90, $BS_MULTILINE)
$cButton_2 = GUICtrlCreateButton("Delete" & @CRLF & "'Just the once'", 110, 220, 100, 90, $BS_MULTILINE)
$cButton_3 = GUICtrlCreateButton("Change Back & Forth", 220, 220, 90, 90, $BS_MULTILINE)

GUISetState()

; Look for the TaskBar
Find_Taskbar($aMarquee_Coords)
; Create the banner marquee
If @error Then
    MsgBox(0, "Error", "Could not find taskbar")
Else
    Global $sText = "I can be set to either the top or bottom of the display - just click on the tray icon and you can switch me !"
    ; Create ticker
    $hGUI = GUICreate("Marquee Example 2", $aMarquee_Coords[2], $aMarquee_Coords[3], $aMarquee_Coords[0], $aMarquee_Coords[1], $WS_POPUPWINDOW, $WS_EX_TOPMOST)
    $aMarquee[7] = _GUICtrlMarquee_Init()
    _GUICtrlMarquee_SetScroll($aMarquee[7], 0, Default, "left", Default, 50)
    _GUICtrlMarquee_SetDisplay($aMarquee[7], 1, 0xFFFF00, 0x88CCFF, 26, "Comic Sans MS")
    _GUICtrlMarquee_Create($aMarquee[7], $sText, 0, 0, $aMarquee_Coords[2], $aMarquee_Coords[3])

    GUISetState()

EndIf

; Create the tray menu
Opt("TrayOnEventMode", 1) ; Use event trapping for tray menu
Opt("TrayMenuMode", 3)    ; Default tray menu items will not be shown.
; Only add ticker position options if ticker exists
If WinExists($hGUI) Then
    Global $hTray_Top_Item = TrayCreateItem("Top")
    TrayItemSetOnEvent(-1, "On_Place")
    Global $hTray_Bot_Item = TrayCreateItem("Bottom")
    TrayItemSetOnEvent(-1, "On_Place")
    TrayCreateItem("")
EndIf
TrayCreateItem("Exit")
TrayItemSetOnEvent(-1, "On_Exit")

TraySetState()

; main loop
While 1
    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
        Case $cButton_1
            _GUICtrlMarquee_Reset($aMarquee[0], "New text set at " & @HOUR & ":" & @MIN & ":" & @SEC)
        Case $cButton_2
            GUICtrlSetState($cButton_2, $GUI_DISABLE)
            _GUICtrlMarquee_Delete($aMarquee[5])
        Case $cButton_3
            GUICtrlSetState($cButton_3, $GUI_DISABLE)
            ; Change type of scroll
            _GUICtrlMarquee_SetScroll($aMarquee[1], -1, "scroll", "right", -1)
            ; Change colours and font
            _GUICtrlMarquee_SetDisplay($aMarquee[1], 2, 0x0000FF, 0xCCFFCC, 14, "Courier New")
            ; And redisplay
            _GUICtrlMarquee_Reset($aMarquee[1], "All different now!")
    EndSwitch
WEnd

Func On_Exit()
    Exit
EndFunc

Func On_Place()

    ; Switch ticker position flag
    If $fMarquee_Pos = "top" Then
        $fMarquee_Pos = "bottom"
    Else
        $fMarquee_Pos = "top"
    EndIf
    ; Find taskbar position and move ticker
    Find_Taskbar($aMarquee_Coords)
    WinMove($hGUI, "", $aMarquee_Coords[0], $aMarquee_Coords[1], $aMarquee_Coords[2], $aMarquee_Coords[3])

EndFunc

Func Find_Taskbar(ByRef $aMarquee_Coords)

    ; Find taskbar and get size
    Local $iPrevMode = AutoItSetOption("WinTitleMatchMode", 4)
    Local $aTaskBar_Pos = WinGetPos("[CLASS:Shell_TrayWnd]")
    AutoItSetOption("WinTitleMatchMode", $iPrevMode)

    ; If error in finding taskbar
    If Not IsArray($aTaskBar_Pos) Then Return SetError(1, 0)

    ; Determine position of taskbar
    If $aTaskBar_Pos[1] > 0 Then
        ; Taskbar at BOTTOM so coords of the marquee are
        $aMarquee_Coords[0] = 0
        $aMarquee_Coords[2] = @DesktopWidth
        If $fMarquee_Pos = "top" Then
            $aMarquee_Coords[1] = 0
        Else
            $aMarquee_Coords[1] = @DesktopHeight - $aTaskBar_Pos[3] - 60
        EndIf
    ElseIf $aTaskBar_Pos[0] > 0 Then
        ; Taskbar at RIGHT so coords of the marquee are
        $aMarquee_Coords[0] = 0
        $aMarquee_Coords[2] = @DesktopWidth - $aTaskBar_Pos[2]
        If $fMarquee_Pos = "top" Then
            $aMarquee_Coords[1] = 0
        Else
            $aMarquee_Coords[1] = @DesktopHeight - 60
        EndIf
    ElseIf $aTaskBar_Pos[2] = @DesktopWidth Then
        ; Taskbar at TOP so coords of the marquee are
        $aMarquee_Coords[0] = 0
        $aMarquee_Coords[2] = @DesktopWidth
        If $fMarquee_Pos = "top" Then
            $aMarquee_Coords[1] = $aTaskBar_Pos[3]
        Else
            $aMarquee_Coords[1] = @DesktopHeight - 60
        EndIf
    ElseIf $aTaskBar_Pos[3] = @DesktopHeight Then
        ; Taskbar at LEFT so coords of the marquee are
        $aMarquee_Coords[0] = $aTaskBar_Pos[2]
        $aMarquee_Coords[2] = @DesktopWidth - $aTaskBar_Pos[2]
        If $fMarquee_Pos = "top" Then
            $aMarquee_Coords[1] = 0
        Else
            $aMarquee_Coords[1] = @DesktopHeight - 60
        EndIf
    EndIf

EndFunc