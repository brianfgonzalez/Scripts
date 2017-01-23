#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=tbicon.ico
#AutoIt3Wrapper_Outfile=Install.exe
#AutoIt3Wrapper_Res_Comment=Contact imaging@us.panasonic.com for support.
#AutoIt3Wrapper_Res_Description=OneClick Panasonic Toughbook Installer.
#AutoIt3Wrapper_Res_Fileversion=1.5.3.0
#AutoIt3Wrapper_Res_LegalCopyright=Panasonic Corporation Of North America
#AutoIt3Wrapper_Res_Language=1033
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
$sInstallVersion = "1.5.3"
$sLogFolderPath = @WindowsDir & "\Temp"
FileInstall("7za.exe", @WindowsDir & "\Temp\7za.exe", 1)
FileInstall("HideCmdWindowEvery3Sec.exe", @WindowsDir & "\Temp\HideCmdWindowEvery3Sec.exe", 1)
;** AUT2EXE settings
;================================================================================================================
; Panasonic Toughbook Parent Script
;  By Brian Gonzalez
;
; Purpose: Installs all drivers from the first discovered subfolder using
;	the PInstall.bat scripts.
;================================================================================================================
; Changelog
;================================================================================================================
; 1.0 - Dec 12 2012
;	Added step to delete (pop) Optional Drivers from DriverZips Array.
; 1.1 - Dec 21 2012
;	Added PNPCheck function, corrected count of elements in driver array.
;	Added TASKKILL call at end of script to close CmdWindowEvery3Sec.exe
;	Updated .ICOs for both HideCmdWindowEvery3Sec.exe and install.exe
;	Also compiled code with PanaConsulting icon.
;	Cleaned up Progress Bar Display by adding Bundle Name and removing File Extension
; 1.2 - Jan 31 2013
;	Changed "##" o pre-fix used for skipped application/driver installs.
; 1.2.1 - Feb 4 2013
;	Changed script to dymanically search for Sub-Folder name and not rely on "src\" name.
; 1.2.2 - Apr 17, 2013
;	Changed all C:\Windows strings to @WindowsDir
; 1.2.3 - May 14, 2013
;	Set install.exe to perform an ArraySort on the $aDriverZips and not rely on the OS for correct sorting.
; 1.2.4 - May 29, 2013
;	Shortened the name of each step displayed to 35 characters.
;	Set the current install to skip if its already been run in the past.
; 1.3 - Dec 16, 2013
;	Changed C:\ calls to SystemDrive
;	Added call to DLL to disable 64-Bit Redirection
;	Added ability to redirect log file to alternate Directory using argument 1
;	Added log redirection within PInstalls as well.  Add "%1" within log for log folder redirection.
; 1.3.2 - Dec 22, 2013
;	Set argument passed to PInstall to 2ND arg, as 1st is used in standard PInstalls already.
; 1.3.3 - Sep 25, 2014
;	Deletes any produced .log files in the root of the SystemDrive.
;	Added additional step to force copy of .ZIP before extraction.
; 1.4 - Oct 3, 2014
;	Set Install.exe to copy Changelog and also pull bundle version number.
;	Adding logging for deleting of log files from root of SystemDrive.
; 1.4.1 - Oct 6, 2014
;	Corrected issue with Bundle-Changelog Copy script.
; 1.4.2 - Oct 7, 2014
;	Added Bundle Version to Install Header, and Log File.
;	Added full path to log file for .ZIP being extracted.
;	Reset the Bottom Progress Bars after each copy if complete.
;	Output install86 and install64 EXEs.
;	Set Install.exe to kill BDDRun.exe when complete. To fix BDDRun getting hung.
; 1.4.3 - Oct 8, 2014
;	Re-Enabled 64Bit Re-Direction.
; 1.4.4 - Nov 5, 2014
;	Added support to pass argument to Kill BDD.
; 1.4.5 - Nov 5, 2014
;	- Removed support for changing logging path as only 1 argument is allowed via -sp1 command.
;	- Set Script to Delete Driver ZIP files after copying them local.
; 1.4.6 - Feb 20, 2015
;	- Set up delete routine to only occur if "temp" is found in ZipPath.
; 1.4.7 - Mar 04, 2015
;	- Corrected logic used to delete zippath.
;	- Set script to delete 7za.exe and HideCmdWindowEvery3Sec.exe at end of script.
; 1.5 - Feb 22, 2016
;	- Added /killBDD and /logPath arguments and set logfile to overwrite itself.
;	- Added #RequireAdmin autoit function.
;	- Set up the Bundle_Changelog and Install_Changelog to be purged when running fresh OCB.
; 1.5.1 - Mar 21, 2016
; 1.5.2 - Apr 6, 2016
;	- Commented out portion of install that skips existing install.zips.
;	- Added logging for sBDDKill var.
; 1.5.3 - Apr 22, 2016
;	- Commented out code pertaining to KillBDD functionality, as it was causing errors.
;================================================================================================================
; AutoIt Includes
;================================================================================================================
#include <Date.au3>
#include <File.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
;================================================================================================================
; Main Routine
;================================================================================================================
AutoItSetOption("MustDeclareVars", 0)
Dim $aPNPIDContents[100] ;Array used when checking through the PNPID txt file
Local $StartTimer = TimerInit()

;If Not IsAdmin() Then ; Verifies user is Admin
;	MsgBox(0, "", "User is not an administrator.  Exiting script.")
;	Exit
;EndIf

If $cmdLine[0] > 0 Then

	For $i = 1 To $cmdLine[0]
		;MsgBox(0, "", "Full Argument: " & $cmdLine[$i])
		If StringInStr($cmdLine[$i], "/?") Or _
			StringInStr($cmdLine[$i], "-?") Or _
			StringInStr($cmdLine[$i], "?") Or _
			StringInStr($cmdLine[$i], "help") Then

			;MsgBox(64, "Help information", "use ""/logPath="" to re-route log file" & @CRLF & _
			;	"use ""/killBDD=1"" to force OCB to kill BDD upon completion" & @CRLF & _
			;	"for silent run with NO arguments.")
			MsgBox(64, "Help information", "use ""/logPath="" to re-route log file" & @CRLF & _
				"for silent run with NO arguments.")
			Exit
		EndIf

		If StringInStr($cmdLine[$i], "/logPath") Then
			$splitArg = StringSplit($cmdLine[$i], "=")
			If $splitArg[0] > 1 Then
				If StringRight($splitArg[2],5)=".log""" Or _
				StringRight($splitArg[2],4)=".log" Or _
				StringRight($splitArg[2],5)=".txt""" Or _
				StringRight($splitArg[2],4)=".txt" Then
					$sLogFile = FileOpen($splitArg[2], 1)
					If $sLogFile = -1 Then
						MsgBox(16, "logPath error", "Unable to access/create log file (" & $splitArg[2] & ").")
						Exit
					EndIf
				Else
					PromptError("logPath", $splitArg[2])
				EndIf
		Else
				PromptError("logPath")
			EndIf
		EndIf
	Next
Else
	; Create LogFile
	$sLogFile = FileOpen($sLogFolderPath & "\PanaInstall_" & @YEAR & @MON & @MDAY & "_" & @HOUR & @MIN & ".log", 2)
	If $sLogFile = -1 Then
		MsgBox(16, "logPath error", "Unable to access/create log file (" & $sLogFile & ").")
		Exit
	EndIf
EndIf
FileWriteLine($sLogFile, "=========================================")
;FileWriteLine($sLogFile, "CmdLineRaw: " & $CmdLineRaw)
;If StringInStr($CmdLineRaw, "/BDDKill=1") Then
;	$sBDDKill = "True"
;	FileWriteLine($sLogFile, "sBDDKill: True")
;Else
;	$sBDDKill = "False"
;	FileWriteLine($sLogFile, "sBDDKill: False")
;EndIf

Func PromptError($error, $info="Not Specified")
	Switch $error
		Case "logPath"
			MsgBox(16, "Error in logPath argument", "Syntex error in logPath,  please include full path to logfile (i.e. /logPath:""C:\MyLogs\MyLog.log"")" & @CRLF & "Specified logPath: " & $info)
			Exit
	EndSwitch
EndFunc

; Tag LogFile with Start Date and Time
FileWriteLine($sLogFile, "Start Date/Time Stamp: " & _Now())

; Grab Sub-Folder path containing driver zip files
$cFoldersOnly = 2
$aSubFolders = _FileListToArray(@ScriptDir, "*", $cFoldersOnly)
$sSrcFolderName = $aSubFolders[1]
$sSrcPath = @ScriptDir & "\" & $aSubFolders[1]
;MsgBox(0, "", "SourcePath: " & $sSrcFolderName)

; Grab SystemDrive
$sSystemDrive = EnvGet("systemdrive"); Sets the System Drive for the Customer Computer

; Disable 64-Bit Redirection
DllCall("kernel32.dll", "int", "Wow64DisableWow64FsRedirection", "int", 1)
FileWriteLine($sLogFile, "Disabled 64Bit Redirection via DLL call.")

; Copy Changelogs local and pull bundle version number from "CurrentVersion=" in bundle_changelog.txt file
FileDelete($sSystemDrive & "\Drivers\*.txt")
FileCopy(@ScriptDir & "\*.txt", $sSystemDrive & "\Drivers\", 8)
If FileExists($sSystemDrive & "\Drivers\Bundle_Changelog.txt") Then
	Local $file = FileOpen($sSystemDrive & "\Drivers\Bundle_Changelog.txt", 0)
	; Read in lines of text until the EOF is reached
	While 1
		Local $line = FileReadLine($file)
		If @error = -1 Then ExitLoop
		;MsgBox(0, "Line read:", $line)
		If StringInStr($line, "CurrentVersion") Then
			$sBundleVersion = StringReplace(StringReplace($line, "CurrentVersion=", ""), " ", "")
			ExitLoop
		EndIf
	WEnd
Else
	$sBundleVersion = "Not Found"
EndIf

; Add more information to the log file
FileWriteLine($sLogFile, "Beginning to Process Bundle Name: " & $sSrcFolderName)
FileWriteLine($sLogFile, "Bundle Version: " & $sBundleVersion)
FileWriteLine($sLogFile, "Script Version: " & $sInstallVersion)
FileWriteLine($sLogFile, "=========================================")

; Populate array with all zip files inside of "src" sub-folder
$sFilesOnly = 1
If FileExists($sSrcPath) Then
	$aDriverZips = _FileListToArray($sSrcPath, "*.zip", $sFilesOnly)
	_ArraySort($aDriverZips, 0, 1)
	;_ArrayDisplay($aDriverZips)
EndIf

; Start Looping program to hide Command Line Windows
;Check if .ZIPs array was populated, if not exit
If @error = 1 Then
	MsgBox(0, "", "No Driver Folders found in \ sub-folder. Exiting script.")
	Exit
EndIf

; Delete Optional Installs (##_) from DriverZips Array
_ArrayDelete($aDriverZips, 0) ;Delete Orig Array Count from Array
$sDriverZips = _ArrayToString($aDriverZips, ",")
$sTestQuery = '\Q##_\E.*?,'
$sDriverZipsNoOptionals = StringRegExpReplace($sDriverZips, $sTestQuery, "")
$aDriverZips = StringSplit($sDriverZipsNoOptionals, ",")

; Kick off Hide Command Shell Program
$sHideCmdWindowPath = @WindowsDir & "\Temp\HideCmdWindowEvery3Sec.exe"
If FileExists($sHideCmdWindowPath) Then
	Run($sHideCmdWindowPath, @ScriptDir, @SW_HIDE)
	FileWriteLine($sLogFile, "Kicked off " & $sHideCmdWindowPath & "):" & @error)
Else
	FileWriteLine($sLogFile, $sHideCmdWindowPath & " not found.")
EndIf

; Copy 7za.exe locally to process ZIP packages
$s7ZAPath = @WindowsDir & "\Temp\7za.exe"
; First Make Sure 7za.exe Exists.
If Not (FileExists($s7ZAPath)) Then
	FileWriteLine($sLogFile, $s7ZAPath & " was not found, exiting script.")
	Exit
EndIf
FileCopy($s7ZAPath, @TempDir, 9) ; 9 = Overwrite and Create Dest Dir
FileWriteLine($sLogFile, "Copied 7za.exe to TempDir(" & @TempDir & "):" & @error)

; Begin to process ZIP files
FileWriteLine($sLogFile, "Beginning to process resource folders(src):" & $aDriverZips[0])

; Calculate amount of steps
$sTotalSteps = $aDriverZips[0] * 4
$sCurrentStep = 0
$sCurrentPercentComplete = fGrabPercentComplete(0)

; Create ProgressBar GUI
$oGUI = GUICreate("Panasonic Driver Installer (Install v" & $sInstallVersion & ") (Bundle Version v" & $sBundleVersion & ")", 600, 130, 0, 0, $WS_BORDER, $WS_EX_TOPMOST) ;width, height, top, left
$oCompleteProgressLabel = GUICtrlCreateLabel("Complete Process:", 5, 10, 100, 20) ;left, top, width, height
$oCompleteProgressBar = GUICtrlCreateProgress(100, 5, 490, 20, $PBS_SMOOTH)
$oCompletePercentLabel = GUICtrlCreateLabel("", 100, 30, 100, 20)
$oCompleteProgressText = GUICtrlCreateLabel("", 200, 30, 385, 20, $SS_RIGHT)
$oStepProgressLabel = GUICtrlCreateLabel("Current Step:", 5, 65, 100, 20)
$oStepProgressBar = GUICtrlCreateProgress(100, 60, 490, 20, $PBS_SMOOTH)
$oStepPercentLabel = GUICtrlCreateLabel("", 100, 85, 100, 20)
$oStepProgressText = GUICtrlCreateLabel("", 200, 85, 385, 20, $SS_RIGHT)
GUISetState()

fProgressBars(0, "Beginning Tbook Installer...", 0, "")

; Begin cycling through Driver ZIPs
For $i = 1 To $aDriverZips[0]
	$sDriverZipPath = $sSrcPath & "\" & $aDriverZips[$i]
	$sDriverName = StringLeft($aDriverZips[$i], StringLen($aDriverZips[$i]) - 4) ;Remove file extension when updating progress bars
	If StringLen($sDriverName) > 35 Then
		$sDriverName = StringLeft($sDriverName, 35) ;If name is longer than 8 characters, shorten the name.
	EndIf

	; fProgressBars args: complete percent, text, step percent, text
    $sCurrentStep = $sCurrentStep + 1
	$sCurrentPercentComplete = fGrabPercentComplete($sCurrentStep)
	fProgressBars($sCurrentPercentComplete, "Copying " & $i & " of " & $aDriverZips[0] & " packages in " & $sSrcFolderName & " bundle.", 0, "Copying " & $sDriverName)
	FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Beggining to copy driver zip """ & $sDriverZipPath & """ to (" & @TempDir & "\" & $sSrcFolderName & "\)")
	;MsgBox(0, "", FileGetLongName(@TempDir & "\" & $sSrcFolderName & "\"))
	$ret = FileCopy($sDriverZipPath, (@TempDir & "\" & $sSrcFolderName & "\"), 9)
	fProgressBars($sCurrentPercentComplete, "Copying " & $i & " of " & $aDriverZips[0] & " packages in " & $sSrcFolderName & " bundle.", 100, "Copying " & $sDriverName)
	; Delete ZipPath if the word "temp" is found anywhere in pathname.
	If StringInStr($sDriverZipPath, "temp") Then
		$ret = FileDelete($sDriverZipPath)
		FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Deleted driver zip """ & $sDriverZipPath & """:" & $ret)
	EndIf
	Sleep(750)
Next

; Begin cycling through Driver ZIPs
For $i = 1 To $aDriverZips[0]
	$sDriverZipPath = @TempDir & "\" & $sSrcFolderName & "\" & $aDriverZips[$i]
	$sDriverName = StringLeft($aDriverZips[$i], StringLen($aDriverZips[$i]) - 4) ;Remove file extension when updating progress bars

	;If FileExists($sSystemDrive & "\Drivers\" & $sSrcFolderName & "\" & $sDriverName) Then
	;	FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- " & $sSystemDrive & "\Drivers\" & $sSrcFolderName & "\" & $sDriverName & " already exist, jumping to next .ZIP")
	;	ContinueLoop
	;EndIf

	If StringLen($sDriverName) > 35 Then
		$sDriverName = StringLeft($sDriverName, 35) ;If name is longer than 8 characters, shorten the name.
	EndIf
	FileWriteLine($sLogFile, "Processing " & $i & " of " & $aDriverZips[0] & "... (" & @TempDir & "\" & $sSrcFolderName & "\" & $aDriverZips[$i] & ")")

	$sDriverExtractFolder = $sSystemDrive & "\Drivers\" & $sSrcFolderName & "\" & StringTrimRight($aDriverZips[$i], 4) ; Specify extract folder, driver name without extension
	$sCurrentStep = $sCurrentStep + 1
	$sCurrentPercentComplete = fGrabPercentComplete($sCurrentStep)
	fProgressBars($sCurrentPercentComplete, "Processing " & $i & " of " & $aDriverZips[0] & " packages in " & $sSrcFolderName & " bundle.", 33, "Extracting " & $sDriverName)
	FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Beggining to extract driver """ & $aDriverZips[$i] & """ from (" & $sDriverZipPath & ")")
	$sRet = RunWait("cmd.exe /c 7za.exe x """ & $sDriverZipPath & """ -o""" & $sSystemDrive & "\Drivers\" & $sSrcFolderName & "\*"" -y", @TempDir, @SW_HIDE)
	FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Completed extracting driver """ & $aDriverZips[$i] & """ to (" & $sDriverExtractFolder & "): " & $sRet)
	$ret = FileDelete($sDriverZipPath)
	FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Deleted driver zip """ & $sDriverZipPath & """:" & $ret)
	$sCurrentStep = $sCurrentStep + 1
	$sCurrentPercentComplete = fGrabPercentComplete($sCurrentStep)
	fProgressBars($sCurrentPercentComplete, "Processing " & $i & " of " & $aDriverZips[0] & " packages in " & $sSrcFolderName & " bundle.", 66, "Installing " & $sDriverName)
	If FileExists($sDriverExtractFolder & "\pnpid.txt") Then
		_FileReadToArray($sDriverExtractFolder & "\pnpid.txt", $aPNPIDContents)
		FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- PNPID file found, beginning WMI check for Device: " & $aPNPIDContents[1])
		If PNPCheck($aPNPIDContents[1]) Then
			FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- PNP Check returned successful for PNPID:" & $aPNPIDContents[1] & ": ")
			FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Beginning to execute the PInstall.bat from extracted driver as PNPID Check returned successfull (" & $sDriverExtractFolder & "): ")
			$sCmd = "cmd.exe /c pinstall.bat """" """ & $sLogFolderPath & """"
			FileWriteLine($sLogFile, "Executing: """ & $sCmd & """" & ", from the following Directory: " & $sDriverExtractFolder)
			$sRet = RunWait($sCmd, $sDriverExtractFolder, @SW_HIDE)
		Else
			FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Skipping install as PNPID Check returned Failed (" & $sDriverExtractFolder & "): ")
		EndIf
	Else
		FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Beginning to execute the PInstall.bat from extracted driver (" & $sDriverExtractFolder & "): ")
		$sCmd = "cmd.exe /c pinstall.bat """" """ & $sLogFolderPath & """"
		FileWriteLine($sLogFile, "Executing: """ & $sCmd & """" & ", from the following Directory: " & $sDriverExtractFolder)
		; Execution of PInsall
		$sRet = RunWait($sCmd, $sDriverExtractFolder, @SW_HIDE)
	EndIf
	$sCurrentStep = $sCurrentStep + 1
	$sCurrentPercentComplete = fGrabPercentComplete($sCurrentStep)
	fProgressBars($sCurrentPercentComplete, "Processing " & $i & " of " & $aDriverZips[0] & " packages in " & $sSrcFolderName & " bundle.", 100, "Install of " & $sDriverName & " is complete.")
	Sleep(750) ; Delay to let user see install completed.
	FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Completed executing the PInstall.bat from extracted driver (" & $sDriverExtractFolder & "): " & $sRet)

Next

;Delete any .log files created in the root of the SystemDrive
$AmountOfSecondsRun = TimerDiff($StartTimer/1000)
$aLogFilesOnSysDrive = _FileListToArray($sSystemDrive, "*.log", $sFilesOnly)

;Check if .ZIPs array was populated, if not exit
If NOT @error = 1 Then
   For $i = 1 To $aLogFilesOnSysDrive[0]
	   $TempLogFilePath = $sSystemDrive & "\" & $aLogFilesOnSysDrive[$i]
	   $t = FileGetTime($TempLogFilePath, $FT_CREATED, 0)
	   ;_ArrayDisplay($t)
	   Local $Date = $t[0] & '/' & $t[1] & '/' & $t[2] & ' ' & $t[3] & ':' & $t[4] & ':' & $t[5]
	   If (_DateDiff('s', $Date, _NowCalc()) <= $AmountOfSecondsRun) Then
		   FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Deleting logfile (" & $TempLogFilePath & "): " & $sRet)
		   FileDelete($TempLogFilePath)
	   EndIf
   Next
EndIf

FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Script Execution is complete.")
$sRet = Run("TASKKILL /F /T /IM HideCmdWindowEvery3Sec.exe", @WindowsDir, @SW_HIDE)
FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Killed HideCmdWindowEvery3Sec.exe Process: " & $sRet)
; Delete 7za.exe and HideCmdWindowEvery3Sec.exe
FileDelete($s7ZAPath)
FileDelete($sHideCmdWindowPath)
;If $sBDDKill = "True" Then
;	FileWriteLine($sLogFile, @HOUR & ":" & @MIN & "--- Killing BDDRun.exe Process")
;	$sRet = Run("TASKKILL /F /T /IM BDDRun.exe", @WindowsDir, @SW_HIDE)
;EndIf
FileClose($sLogFile)

;================================================================================================================
; Functions and Sub Routines
;================================================================================================================
Func fGrabPercentComplete($sCurrentStep)
	Return Round(($sCurrentStep / $sTotalSteps) * 100)
EndFunc   ;==>fGrabPercentComplete

Func fProgressBars($sCompleteBarPerc, $sCompleteBarText, $sStepBarPerc, $sStepBarText) ;complete percent, text, step percent, text
	GUICtrlSetData($oCompleteProgressBar, $sCompleteBarPerc)
	GUICtrlSetData($oCompleteProgressText, $sCompleteBarText)
	GUICtrlSetData($oCompletePercentLabel, $sCompleteBarPerc & "%")
	GUICtrlSetData($oStepProgressBar, $sStepBarPerc)
	GUICtrlSetData($oStepProgressText, $sStepBarText)
	GUICtrlSetData($oStepPercentLabel, $sStepBarPerc & "%")
EndFunc   ;==>fProgressBars

Func PNPCheck($sPNPID)
	$sPNPID = StringReplace($sPNPID, '\', '%') ;Clean up PNPID string
	$objWMIService = ObjGet("winmgmts:\\.\root\cimv2")
	$sQuery = "Select * FROM Win32_PNPEntity WHERE DeviceID LIKE '%" & $sPNPID & "%'"
	$colPNPEntity = $objWMIService.ExecQuery($sQuery)
	Return $colPNPEntity.Count
EndFunc   ;==>PNPCheck