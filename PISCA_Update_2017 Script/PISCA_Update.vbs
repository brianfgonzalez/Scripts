'======================================================================================================================
'
' NAME:  PISCA_Update-V2
' Organization: Panasonic Information Systems Company America (PISCA) 
' Division of Panasonic Corporation of North America 
'
' DATE  : 08/12/2016
' COMMENT: Update to check if iTWatch is installed.   
'
'======================================================================================================================


Dim compSerial, sUser, sComputer, strShowInterace, IMEI, userFullName, iTWatch, taskAnswer

'Initialize objects


Set objShell = CreateObject("WScript.Shell")  
Set objFSO = CreateObject("Scripting.FileSystemObject")

strComputer = "."
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
Set colSettings = objWMIService.ExecQuery ("Select * from Win32_ComputerSystem")
For Each objComputer in colSettings         
Next

'Get PC Serial Number
Set colItems = objWMIService.ExecQuery("SELECT * FROM Win32_ComputerSystemProduct") 
For Each objItem in colItems 
     compSerial = ";Serial Number:; " & objItem.IdentifyingNumber
Next
Set colItems = objWMIService.ExecQuery("Select * from Win32_ComputerSystem",,48)
For Each objItem in colItems 
            model= ";Model:; " & objItem.Model
next
'Get userID  and PC Name
Set WshNetwork = WScript.CreateObject("WScript.Network")
sComputer = ";Computer Name:; " & WshNetwork.ComputerName
sUser = ";User ID:; " & WshNetwork.UserName


'GET Gobi IMEI Info
Set objExec = objShell.Exec("netsh mbn show interface")
strShowInterace = ""
Do While Not objExec.StdOut.AtEndOfStream
   strShowInterface = strShowInterface & vbNewLine & objExec.StdOut.ReadLine()
Loop

'Check if found Gobi information by string length.  
If (Len (strShowInterface) > 100) Then
  IMEI = "Gobi IMEI " & Mid(strShowInterface, InStr(strShowInterface, "Device Id"), 38) 'Use Instr and Mid to chapter only device ID Info
  Else
  IMEI = "Gobi IMEI: None Installed"
End If

'Check if iTWatch is installed
iTWatch = ";iTWatch:; No"
If objFSO.FileExists ("C:\Program Files (x86)\Level Platforms\Onsite Manager\Bin\OMDesktop.exe") Then
	iTWatch = ";iTWatch:; Yes"
Else
	If objFSO.FileExists ("C:\Program Files\Level Platforms\Onsite Manager\Bin\OMDesktop.exe") Then
		iTWatch = ";iTWatch:; Yes"
	End If
End If
Set objOutlook = CreateObject("Outlook.Application")
   Set objMail = objOutlook.CreateItem(0)
   objMail.Display   'To display message
   If (taskAnswer = "1") Then
      taskAnswer = "Re-Build, Surplus Machine & Hot Swap"
      objMail.To = "itassetmanager@us.panasonic.com"
      Else
      taskAnswer = "New Device & Transfer"
      objMail.To = "azapata@advancedtech.com;itassetmanager@us.panasonic.com;Fiona.Vu@ext.us.panasonic.com"
   End if
   objMail.Subject = "PISCA PC Asset Audit 2017"
   objMail.HTMLBody = "PISCA User Asset Information"&"<br>"&scomputer&"<br>"&compSerial&"<br>"&model&"<br>"&sUser&"<br>"&iTWatch&"<br>"  
result=Msgbox("Thank you for Submitting your Asset Information")
  
 objmail.send

