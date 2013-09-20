'==========================================================================
' NAME: SearchAndApply....vbs
' AUTHOR: Brian Gonzalez, Panasonic
' UPDATED DATE  : 11/30/2012
' PURPOSE: Recovers a system by re-imaging the disk using either .GHO or .WIM files.

' CHANGELOG:
' Switched FileSearches to use FileSystemObject instead of WMI and added prompt at end to remove boot media. -2011Dec06
' Set Cancel button on sImagePrompt to Exit Script. -2011Sept08
' Added /verify flag to imagex apply call.  Also added ErrorCheck block under ImageX call. -2011Sept13
' Set Image Selection Prompt to Auto-Select image if only one is located. -2011Sept14
' Added "Cancel" button to confirmation prompt to allow users to easily exit the script. -2011Sept14
' Added Support for DVDR usage as well as USB Flash Drive usage. -2012Feb06
' Added Support for a single "SWM" usage in the root of the drive with only 1 split. -2012Feb06
' Added bcdboot line to end of Win7 apply script. -2012May04
' Adjusted ghost command line options to display status and resize first partition to fill drive. -2012May15
' v6 - Set system is shutdown after ghost completes instead of rebooting. -2012May16
' v7 - Cleaned up Vars in script and also used image*.swm for split .WIM files. -2012Nov30
'==========================================================================
'On Error Resume Next
Set oShell = CreateObject("WScript.Shell")
Set oFSO = CreateObject("Scripting.FileSystemObject")

Dim aFileExt(2)
aFileExt(0) = "wim"
aFileExt(1) = "gho"
aFileExt(2) = "swm"
'==========MAIN ROUTINE===================================
If Not fCheckDiskis100() Then 'Verify local disk is 100GB in size
	WScript.Echo "Local Disk is less than 100GB, which means WinPE does not see the local Hard Drive."
	WScript.Quit
End If

sCDDrvLetter = fGetCDRDrvLetter()
If oFSO.FileExists(sCDDrvLetter & "\BOOTMGR") Then
		sImagePaths = fSearchForImageFiles(sCDDrvLetter)
End If

Set cDrvLetters = oFSO.Drives
For Each oDrvLetter In cDrvLetters
	If oDrvLetter.IsReady AND oDrvLetter.DriveType = 1 Then
		sImagePaths = sImagePaths & "," & fSearchForImageFiles(oDrvLetter)
	End If
Next

Wscript.Echo "sImagePaths = " & sImagePaths
ImagePaths = Split(ImagePaths, ",")
ImageSelectionPath = fPromptForImage()
ImageSelectionPath = Trim(ImageSelectionPath)
Wscript.Echo Time & "  ::  Image Selection: " & ImageSelectionPath
ImageSelectionPath = UCASE(ImageSelectionPath)

Select Case Right(ImageSelectionPath, 3)
Case "GHO" 'Symantec Image Type using Ghost32 for apply process
	applyRet = ApplyImageWGhost(ImageSelectionPath)
Case "WIM", "SWM" 'MS Image Type using Imagex for apply process
	applyRet = ApplyImagewImageX(ImageSelectionPath)
Case Else 'No Images found.
	WScript.Echo "No Match was found.  Exiting Script."
	WScript.Quit
End Select


'==============FUNCTIONS==================================
Function fCheckDiskis100()
	Const cWbemFlagReturnImmediately = &h10
	Const cWbemFlagForwardOnly = &h20
	
	Set oWMIService = GetObject("winmgmts:\\.\root\CIMV2")
	Set cItems = oWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive WHERE DeviceID LIKE '%PHYSICALDRIVE0%'")
	For Each oItem In cItems
	 If oItem.Size >= "100000000000" Then
		fCheckDiskis100 = "True"
	 Else
		fCheckDiskis100 = "False"
	 End If
	Next
End Function

Function fGetCDRDrvLetter()
	Const cWbemFlagReturnImmediately = &h10
	Const cWbemFlagForwardOnly = &h20
	
	Set oWMIService = GetObject("winmgmts:\\.\root\CIMV2")
	Set cItems = oWMIService.ExecQuery("SELECT * FROM Win32_LogicalDisk WHERE FileSystem = 'CDFS'", "WQL", _
                   cWbemFlagReturnImmediately + cWbemFlagForwardOnly)
	For Each oItem In cItems
		fGetCDRDrvLetter = oItem.DeviceID
	Next
	
	If Len(fGetCDRDrvLetter) < 2 Then
		fGetCDRDrvLetter = "False"
	End If
End Function

Function fPromptForImage()
	sImagePrompt = "Please select an image to apply: " & vbCrLf
	num = "1"
	
	If UBound(ImagePaths) >= 1 Then
		For Each item In ImagePaths
			sImagePrompt = sImagePrompt & num & " => .." & Right(item, 30) & VbCrLf
			num = num + 1
		Next
		ans = InputBox(UCase(sImagePrompt), "Image Selection Prompt", 1)
	ElseIf UBound(ImagePaths) = -1 Then
		Wscript.Echo "No Images found. Closing Script."
		Wscript.Quit
	Else
		ans = 1
	End If
	
	If IsNumeric(ans) Then
		imageAns = ans - 1
	End If
	
	If ans = -1  Or ans = "" Then
		Wscript.Echo Time & "  ::  Image Selection Prompt was cancelled.  Exiting Script."
		WScript.Quit
	ElseIf imageAns > UBound(ImagePaths) Or Not IsNumeric(imageAns) Or imageAns =< -1  Then
		Wscript.Echo Time & "  ::  Image Selection Answer: " & ans & " is not valid.  Re-Prompting."
		fPromptForImage()
	Else
		ans = oShell.Popup ("Are you sure you want to recover this image: " & VbCrLf & UCase(ImagePaths(imageAns) & VbCrLf & "Image will be auto-selected in 10 seconds.."), 10, "Confirmation Prompt", 32 + 3)
		Select Case ans
		Case -1 'Nothing was clicked
			fPromptForImage = ImagePaths(0)
		Case 2 'Cancel was clicked
			Wscript.Echo Time & "  ::  Image Selection Prompt was cancelled.  Exiting Script."
			WScript.Quit
  		Case 6 'Yes was clicked
  			fPromptForImage = ImagePaths(imageAns)
  		Case 7 'No was clicked
  			fPromptForImage()
    	End Select
    	
	End If
End Function

Function fSearchForImageFiles(sDrvLetter)
	Set oDrvRootFolder = oFSO.GetFolder(sDrvLetter & "\")
	Set oDrvRootFolderFiles = oDrvRootFolder.Files
	For Each oFile in oDrvRootFolderFiles
		sFileName = UCase(oFile.Name)
		If RIGHT(sFileName,3) = "WIM" Or RIGHT(sFileName,3) = "GHO" Or Right(sFileName,3) = "SWM" Then 
			If fSearchForImageFiles = "" Then 'If this is the first find, then simply add.
				fSearchForImageFiles = oFile.path
			Else 'Not the first file, so we need to add the previous finds as well.
				fSearchForImageFiles = fSearchForImageFiles & "," & oFile.path
			End If
		End If
	Next
End Function

Function ApplyImageWGhost(imagePath)
	sCmdPath = "ghost32.exe -clone,mode=restore,src=""" & imagePath & """,dst=1 -BATCH -SZEF"
	sIntReturn = oShell.Run(sCmdPath, 0, True)
	If Not sIntReturn = 0 Then
		WScript.Echo Time & "  ::  Image did not apply succesfully.  Cancelling Script as ""Apply .WIM"" step failed."
		WScript.Quit
	End If

	oShell.Popup "Image was applied, please remove USB or DVD...", 60, "Remove USB/DVD Prompt", 64 + 0

	sCmdPath = "wpeutil shutdown"
	sIntReturn = oShell.Run(sCmdPath, 0, True)	
End Function

Function ApplyImagewImageX(imagePath)

	'Diskpart Drive and 
	ansfilePath = "x:\DiskpartAnswerFile.txt"
	Set objansFile = oFSO.CreateTextFile(ansfilePath, True)
	objansFile.WriteLine "sel dis 0"
	objansFile.WriteLine "clean"
	objansFile.WriteLine "cre par pri align=16065"
	objansFile.WriteLine "format fs=ntfs quick label=osdisk"
	objansFile.WriteLine "active"
	objansFile.WriteLine "assign letter=c"
	
	sCmdPath = "%ComSpec% /C start /w ""Run Diskpart"" diskpart /s """ & ansfilePath & """"
	sIntReturn = oShell.Run(sCmdPath, 3, True)
	
	If s2SWMPath = "" Then
		sCmdPath = "imagex.exe /verify /apply """ & imagePath & """ 1 C:"
	Else
		sCmdPath = "imagex.exe /verify /REF """ & s2SWMPath & """ /apply """ & imagePath & """ 1 C:"
	End If
	sIntReturn = oShell.Run(sCmdPath, 3, True)
	
	If Not sIntReturn = 0 Then
		WScript.Echo Time & "  ::  Image did not apply succesfully.  Cancelling Script as ""Apply .WIM"" step failed."
		WScript.Quit
	End If
	WScript.Echo Time & "  ::  Image did apply succesfully."
	
	WScript.Sleep 2000
	
	If Not oFSO.FileExists("C:\boot.ini") Then
	
		sCmdPath = "bootsect.exe /nt60 C: /force"
		sIntReturn = oShell.Run(sCmdPath, 0, True)
	
		sCmdPath = "bcdboot C:\Windows"
		sIntReturn = oShell.Run(sCmdPath, 3, FALSE)

	Else

		sCmdPath = "bootsect.exe /nt52 C: /force"
		sIntReturn = oShell.Run(sCmdPath, 0, True)

	End If

	oShell.Popup "Image was applied, please remove USB or DVD...", 60, "Remove USB/DVD Prompt", 64 + 0

	sCmdPath = "wpeutil shutdown"
	sIntReturn = oShell.Run(sCmdPath, 0, True)	

End Function
