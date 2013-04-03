;#RequireAdmin
#NoTrayIcon
#include <Date.au3>

; Create Log File
$logfile = FileOpen(@YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & "_Panasonic.log", 1)

; Check if file opened for writing OK
If $logfile = -1 Then
    MsgBox(0, "Error", "Unable to open file.")
    Exit
EndIf

; Tag log file with Start Date and Time
FileWriteLine($logfile, "Start Date/Time Stamp: " & _Now())

; Pull model from machine and store in variable
$WMI = ObjGet("winmgmts:\\.\root\cimv2") ;connect to WMI
$query = $WMI.ExecQuery _
   ("SELECT Model FROM Win32_ComputerSystem") ;query for model number
For $element in $query
   $model = $element.Model ;Grab model into variable
Next
FileWriteLine($logfile, "Model: " & $model)

;Populate the shortmodel variable
$shortmodel = StringLeft($model, 6)
FileWriteLine($logfile, "Short Model: " & $shortmodel)

; Perform "Select Case" to compare model against available drivers store
Select
Case $shortmodel = "CF-53J"
   $bundle = @ScriptDir & "\CF52Mk2L7x86Bundle"
Case $shortmodel = "CF-52G"
   $bundle = @ScriptDir, "\52Mk2L7x86Bundle"
EndSelect
; Copy drivers local and enumerate through folders running pinstalls
; Verify script is being run local on disk
If Not DriveGetType(@ScriptFullPath) = "Fixed" Then
   FileWriteLine($logfile, "Script is not local on disk. Copying routine will begin.")
   ;Running of Removable media, so now copy to C: Drive
   DirCopy(@ScriptFullPath, "C:\Drivers", 1)
   FileWriteLine($logfile, "Script copy is complete, now executing copied script.")
   ;Now run copied script to run local
   Run("C:\Drivers\" & @ScriptName, "C:\Drivers", @SW_HIDE)
   ;Exit this script, as we started another copy from the C: Drive
   Exit
EndIf

; Tag log file with End Date and Time
FileWriteLine($logfile, "End Date/Time Stamp: " & _Now())
FileClose($logfile)