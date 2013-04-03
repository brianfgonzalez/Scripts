#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

fProgressBars()

Func fProgressBars()
   Local $oGUI, $oCompleteProgressBar, $oCompleteProgressLabel, $oCompleteProgressText, $oStepProgressBar, $oStepProgressLabel, $oStepProgressText, $StartButton

   $oGUI = GUICreate("Panasonic Driver Installer", 600, 130, 0, 0, $WS_BORDER, $WS_EX_TOPMOST)
   $oCompleteProgressLabel = GUICtrlCreateLabel("Complete Process:", 5, 10, 100, 20) ;left, top, width, height
   $oCompleteProgressBar = GUICtrlCreateProgress( 100, 5, 490, 20, $PBS_SMOOTH)
   $oCompletePercentLabel = GUICtrlCreateLabel("10%", 100, 30, 100, 20)
   $oCompleteProgressText = GUICtrlCreateLabel("", 200, 30, 385, 20, $SS_RIGHT)
   
   $oStepProgressLabel = GUICtrlCreateLabel("Current Step:", 5, 65, 100, 20)
   $oStepProgressBar = GUICtrlCreateProgress( 100, 60, 490, 20, $PBS_SMOOTH)
   $oStepPercentLabel = GUICtrlCreateLabel("10%", 100, 85, 100, 20)
   $oStepProgressText = GUICtrlCreateLabel("", 200, 85, 385, 20, $SS_RIGHT)
    ;GUICtrlSetColor(-1, 32250); not working with Windows XP Style
    $StartButton = GUICtrlCreateButton("Start", 5, 105, 70, 20)
    GUISetState()

	GUICtrlSetData($oCompleteProgressText, "This is an example of setting the complete progress text" & "...")
	GUICtrlSetData($oStepProgressText, "This is an example of setting the step progress text" & "...")
	
    $wait = 20; wait 20ms for next progressstep
    $s = 0; progressbar-saveposition
    Do
        $msg = GUIGetMsg()
        If $msg = $StartButton Then
            GUICtrlSetData($StartButton, "Stop")
            For $i = $s To 100
                If GUICtrlRead($oCompleteProgressBar) = 50 Then MsgBox(0, "Info", "The half is done...", 1)
                $m = GUIGetMsg()

                If $m = -3 Then ExitLoop

                If $m = $StartButton Then
                    GUICtrlSetData($StartButton, "Next")
                    $s = $i;save the current bar-position to $s
                    ExitLoop
                Else
                    $s = 0
                    GUICtrlSetData($oCompleteProgressBar, $i)
                    GUICtrlSetData($oStepProgressBar, (100 - $i))
                    Sleep($wait)
                EndIf
            Next
            If $i > 100 Then
                ;       $s=0
                GUICtrlSetData($StartButton, "Start")
            EndIf
        EndIf
    Until $msg = $GUI_EVENT_CLOSE
EndFunc   ;==>Example
