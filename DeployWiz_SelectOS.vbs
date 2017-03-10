' // ***************************************************************************
' // 
' // Copyright (c) Microsoft Corporation.  All rights reserved.
' // 
' // Microsoft Deployment Toolkit Solution Accelerator
' //
' // File:      DeployWiz_SelectOs.vbs
' // 
' // Version:   6.3.8443.1000
' // 
' // Purpose:
' // 
' // ***************************************************************************
Option Explicit
Dim g_oXMLOsList

Function fInitializeOsList
	If IsEmpty(g_oXMLOsList) then
		Set g_oXMLOsList = new ConfigFile
		g_oXMLOsList.sFileType = "OperatingSystems"
		g_oXMLOsList.sHTMLPropertyHook = " onPropertyChange='fOsItemChange'"
	End if
	If oEnvironment.Item("TaskSequenceID") = "DEP-NS-001" then
		oEnvironment.Item("OSGUID") = ""
		ButtonNext.Disabled = TRUE
	End If
	OsListBox.InnerHTML = g_oXMLOsList.GetHTMLEx ( "Radio", "OsGuid" )
	PopulateElements
End function

Function fOsItemChange
	Dim oInput
	ButtonNext.Disabled = TRUE
	for each oInput in document.getElementsByName("OSGUID")
		If oInput.Checked then
			oLogging.CreateEntry "Found Checked Item: " & oInput.Value, LogTypeInfo
			oEnvironment.Item("OSGUID") = oInput.Value
			oLogging.CreateEntry "OSGUID TS variable set to: " & oEnvironment.Item("OSGUID"), LogTypeInfo
			oEnvironment.Item("OSNAME") = oUtility.SelectSingleNodeString(g_oXMLOsList.FindAllItems.Item(Property("OSGUID")),"./Name")
			oLogging.CreateEntry "OSNAME TS variable found and set to: " & oEnvironment.Item("OSNAME"), LogTypeInfo
			ButtonNext.Disabled = FALSE
			exit function
		End if
	next
End function

Function fValidateOsList
	'Dim g_oXMLOsList2
	'If IsEmpty(g_oXMLOsList2) then
	'	Set g_oXMLOsList2 = new ConfigFile
	'	g_oXMLOsList2.sFileType = "OperatingSystems"
	'End if
	'SaveAllDataElements
	fValidateOsList = TRUE
	'ButtonNext.Disabled = FALSE
End Function