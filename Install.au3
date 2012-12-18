;======================================================================
; Panasonic Toughbook Parent Script
;  By Brian Gonzalez
;
; Purpose: Installs all drivers from "src\" subfolder using
;	the PInstall.bat scripts.
;
; Updated Date: Dec 16, 2012
;
; Changelog:
;	Dec 12- Added step to delete (pop) Optional Drivers from DriverZips
;		Array.  Also compiled code with PanaConsulting icon.
;======================================================================
; AutoIt Includes
;======================================================================
#include <Date.au3>
#include <File.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
;======================================================================
; Main Routine
;======================================================================
If Not IsAdmin() Then ; Verifies user is Admin
	  MsgBox(0, "", "User is not an admin")
	  Exit
EndIf
   
; Create LogFile
$sLogFilePath = "C:\Windows\Temp"
$sLogFile = FileOpen ($sLogFilePath & "\PanaInstall_" & @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & ".log", 1)
If $sLogFile = -1 Then
    MsgBox(0, "Error", "Unable to access/create log file.")
    Exit
EndIf

; Tag LogFile with Start Date and Time
FileWriteLine($sLogFile, "Start Date/Time Stamp: " & _Now())

; Populate array with all zip files inside of "src" sub-folder
$sFilesOnly = 1 ;$foldersOnly = 2
$sSrcPath = @ScriptDir & "\src"
If FileExists($sSrcPath) Then
   $aDriverZips = _FileListToArray($sSrcPath, "*.zip")
EndIf

; Start Looping program to hide Command Line Windows
;Check if .ZIPs array was populated, if not exit
If @error = 1 Then
   MsgBox(0, "", "No Driver Folders found in src\ sub-folder. Exiting script.")
   Exit
EndIf
 
; Delete Optional Installs (99_) from DriverZips Array
$sDriverZips = _ArrayToString($aDriverZips, ",")
$sTestQuery = '\Q99_\E.*?,'
$sDriverZipsNoOptionals = StringRegExpReplace($sDriverZips, $sTestQuery, "")
$aDriverZips = StringSplit($sDriverZipsNoOptionals, ",")

; Kick off Hide Command Shell Program
$sHideCmdWindowPath = @ScriptDir & "\HideCmdWindowEvery3Sec.exe"
If FileExists($sHideCmdWindowPath) Then
   Run($sHideCmdWindowPath, @ScriptDir, @SW_HIDE)
   FileWriteLine($sLogFile, "Kicked off " & $sHideCmdWindowPath)
Else
   FileWriteLine($sLogFile, $sHideCmdWindowPath & " not found.")
EndIf

; Copy 7za.exe locally to process ZIP packages
$s7ZAPath = @ScriptDir & "\7za.exe"
; First Make Sure 7za.exe Exists.
If NOT (FileExists($s7ZAPath)) Then
   FileWriteLine($sLogFile, $s7ZAPath & " was not found, exiting script.")
   Exit
EndIf
FileCopy($s7ZAPath, @TempDir, 9) ; 9 = Overwrite and Create Dest Dir
FileWriteLine($sLogFile, "Copied 7za.exe to TempDir(" & @TempDir & "):" & @Error)

; Begin to process ZIP files
FileWriteLine($sLogFile, "Beginning to process resource folders(src):" & $aDriverZips[0])

; Calculate amount of steps
$sTotalSteps = $aDriverZips[0] * 3
$sCurrentStep = 0
$sCurrentPercentComplete = fGrabPercentComplete(0)

; Create ProgressBar GUI
$oGUI = GUICreate("Panasonic Driver Installer", 600, 130, 0, 0, $WS_BORDER, $WS_EX_TOPMOST) ;width, height, top, left
$oCompleteProgressLabel = GUICtrlCreateLabel("Complete Process:", 5, 10, 100, 20) ;left, top, width, height
$oCompleteProgressBar = GUICtrlCreateProgress(100, 5, 490, 20, $PBS_SMOOTH)
$oCompletePercentLabel = GUICtrlCreateLabel("", 100, 30, 100, 20)
$oCompleteProgressText = GUICtrlCreateLabel("", 200, 30, 385, 20, $SS_RIGHT)
$oStepProgressLabel = GUICtrlCreateLabel("Current Step:", 5, 65, 100, 20)
$oStepProgressBar = GUICtrlCreateProgress(100, 60, 490, 20, $PBS_SMOOTH)
$oStepPercentLabel = GUICtrlCreateLabel("", 100, 85, 100, 20)
$oStepProgressText = GUICtrlCreateLabel("", 200, 85, 385, 20, $SS_RIGHT)
GUISetState()

fProgressBars("Beginning Tbook Installer...", 0, "", 0)

; Begin cycling through Driver ZIPs
For $i = 1 To $aDriverZips[0]
   $sDriverZipPath = @ScriptDir & "\src\" & $aDriverZips[$i]
   FileWriteLine($sLogFile, "Processing " & $i & " of " & $aDriverZips[0] & "... (" & $aDriverZips[$i] & ")")
   fProgressBars($sCurrentPercentComplete, "Processing " & $aDriverZips[$i], 30, "Beginning to process " & $aDriverZips[$i])

   ; fProgressBars args: complete percent, text, step percent, text
   $sDriverExtractFolder = "C:\Drivers\src\" & StringTrimRight($aDriverZips[$i], 4) ; Specify extract folder, driver name without extension
   $sCurrentStep = $sCurrentStep + 1
   $sCurrentPercentComplete = fGrabPercentComplete($sCurrentStep)
   fProgressBars($sCurrentPercentComplete, "Processing " & $i & " of " & $aDriverZips[0] & " packages.", 33, "Extracting " & $aDriverZips[$i])
   FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Beggining to extract driver """ & $aDriverZips[$i] & """ to " & $sDriverExtractFolder)
   RunWait("cmd.exe /c 7za.exe x """ & $sDriverZipPath & """ -o""C:\Drivers\src\*"" -y", @TempDir, @SW_HIDE)
   FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Completed extracting driver """ & $aDriverZips[$i] & """ to " & $sDriverExtractFolder & ", ret code: " & @error)
   $sCurrentStep = $sCurrentStep + 1
   $sCurrentPercentComplete = fGrabPercentComplete($sCurrentStep)
   fProgressBars($sCurrentPercentComplete, "Processing " & $i & " of " & $aDriverZips[0] & " packages.", 66, "Installing " & $aDriverZips[$i])
   FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Beginning to execute the PInstall.bat from extracted driver (" & $sDriverExtractFolder & ")")
   RunWait("cmd.exe /c pinstall.bat", $sDriverExtractFolder, @SW_HIDE)
   $sCurrentStep = $sCurrentStep + 1
   $sCurrentPercentComplete = fGrabPercentComplete($sCurrentStep)
   fProgressBars($sCurrentPercentComplete, "Processing " & $i & " of " & $aDriverZips[0] & " package complete.", 100, "Install of " & $aDriverZips[$i] & " is complete.")
   Sleep(750) ; Delay to let user see install completed.
   FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Completed executing the PInstall.bat from extracted driver (" & $sDriverExtractFolder & "), ret code: " & @error)

Next

GUIDelete($oGUI)
FileClose($sLogFile)

;======================================================================
; Functions and Sub Routines
;======================================================================
Func fGrabPercentComplete($sCurrentStep)
	  Return Round(($sCurrentStep / $sTotalSteps) * 100)
EndFunc

Func fProgressBars($sCompleteBarPerc, $sCompleteBarText, $sStepBarPerc, $sStepBarText) ;complete percent, text, step percent, text
   GUICtrlSetData($oCompleteProgressBar, $sCompleteBarPerc)
   GUICtrlSetData($oCompleteProgressText, $sCompleteBarText)
   GUICtrlSetData($oCompletePercentLabel, $sCompleteBarPerc & "%")
   GUICtrlSetData($oStepProgressBar, $sStepBarPerc)
   GUICtrlSetData($oStepProgressText, $sStepBarText)
   GUICtrlSetData($oStepPercentLabel, $sStepBarPerc & "%")
EndFunc