' // ***************************************************************************
' // 
' // Copyright (c) Microsoft Corporation.  All rights reserved.
' // 
' // Microsoft Deployment Toolkit Solution Accelerator
' //
' // File:      ZTIGrabOldCompName.vbs
' // 
' // Purpose:   Grabs old CompName if avail. and returns to CS.INI.
' // 
' // ***************************************************************************
Function UserExit(sType, sWhen, sDetail, bSkip)
	UserExit=Success
End Function

Function fGrabOldCompName(sDefaultName)
	Dim sOldCompName, sLocalSWHiveFilePath
	oLogging.CreateEntry "UserExit:Pulling computername from local registry.", LogTypeInfo

	If oFSO.FileExists("C:\WINDOWS\system32\config\system") Then
		sLocalSWHiveFilePath = "C:\WINDOWS\system32\config\system"
	ElseIf oFSO.FileExists("D:\WINDOWS\system32\config\system") Then
		sLocalSWHiveFilePath = "D:\WINDOWS\system32\config\system"
	ElseIf oFSO.FileExists("E:\WINDOWS\system32\config\system") Then
		sLocalSWHiveFilePath = "E:\WINDOWS\system32\config\system"
	Else
		sLocalSWHiveFilePath = "FALSE"
	End If
	oLogging.CreateEntry "UserExit:Local system hive location set to: " & sLocalSWHiveFilePath, LogTypeInfo
	
	If sLocalSWHiveFilePath <> "FALSE" Then
		oShell.Run "reg load HKLM\sysimport " & sLocalSWHiveFilePath, 1, True
		sOldCompName = oShell.RegRead("HKLM\sysimport\ControlSet001\Control\ComputerName\ComputerName\ComputerName")
		oShell.Run "reg unload HKLM\sysimport", 1, True
		fGrabOldCompName = sOldCompName
		oLogging.CreateEntry "UserExit:Setting OSDComputerName variable to: " & sOldCompName, LogTypeInfo
	Else
		fGrabOldCompName = sDefaultName
		oLogging.CreateEntry "UserExit:Error locating old computername.  Setting computername to default value: " & sDefaultName, LogTypeError
	End If
End Function