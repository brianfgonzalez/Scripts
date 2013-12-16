$sReturn = WinWaitActive("Sensor Firmware Update", "This program updates Sensor Firmware", 30)
If $sReturn = 0 Then
	MsgBox(0, "Error", "Sensor Firmware update window was not located..")
	Exit
EndIf
WinActivate("Sensor Firmware Update", "")
ControlClick("Sensor Firmware Update", "", "[Class:Button; Instance:1]")

WinWaitActive("Windows Security", "")
WinActivate("Windows Security", "")
Send("!i")

WinWaitActive("Sensor Firmware Update", "Update complete")
WinActivate("Sensor Firmware Update", "")
ControlClick("Sensor Firmware Update", "", "[Class:Button; Instance:1]")