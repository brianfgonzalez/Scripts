' // ***************************************************************************
' // 
' // Copyright (c) Microsoft Corporation.  All rights reserved.
' // 
' // Microsoft Deployment Toolkit Solution Accelerator
' //
' // File:      Summary_scripts.vbs
' // 
' // Version:   6.3.8443.1000
' // 
' // Purpose:   Scripts to initialize and validate summary wizard
' // 
' // ***************************************************************************

Option Explicit

Dim iErrors
Dim iWarnings
Dim sBuffer
Dim sDeploymentType
Dim iDeploymentDuration

Function InitializeSummary

	Dim oResults
	Dim iRetVal


	' Load the results

	If oFSO.FileExists(oEnv("TEMP") & "\Results.xml") then
		Set oResults = oUtility.CreateXMLDOMObjectEx(oEnv("TEMP") & "\Results.xml")
		iErrors = CInt(oUtility.SelectSingleNodeString(oResults, "//Errors"))
		iWarnings = CInt(oUtility.SelectSingleNodeString(oResults, "//Warnings"))
		sBuffer = oUtility.SelectSingleNodeString(oResults, "//Messages")
		iRetVal = oUtility.SelectSingleNodeString(oResults, "//RetVal")	
		sDeploymentType = oUtility.SelectSingleNodeString(oResults, "//DeploymentType")
'////////////
		iDeploymentDuration = oUtility.SelectSingleNodeString(oResults, "//DeploymentDuration")
'\\\\\\\\\\\\
	Else
		iErrors = 0
		iWarnings = 1
		sBuffer = "Unable to locate the Results.xml file needed to determine the deployment results.  "
		sBuffer = sBuffer & "(This may be the result of mismatched script versions.  Ensure all boot images have been updated.)"
	End if
	

	' If this is a replace, then modifiy the title

	If sDeploymentType = "REPLACE" then
		NormalTitle.style.display = "none"
		ReplaceTitle.style.display = "inline"
	End if


	' Set the background color based on the return code

	If iRetVal = "0" or iRetVal = "" then
		If iErrors > 0 or iWarnings > 0 then
			MyContentArea.style.backgroundColor = "yellow"
		End if
	Else
		MyContentArea.style.backgroundColor = "salmon"
	End if

	' Update the dialog
	ErrorCount.InnerText = CStr(iErrors)
	WarningCount.InnerText = CStr(iWarnings)
	optionalWindow1.InnerText = sBuffer
'////////////
	DeploymentDuration.InnerText = iDeploymentDuration
'\\\\\\\\\\\\
	buttonCancel.disabled = true
	

End Function
