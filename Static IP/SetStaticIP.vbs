Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\.\root\cimv2")
Set objShell = WScript.CreateObject("WScript.Shell")

Set colItems = objWMIService.ExecQuery("Select * from Win32_ComputerSystem")

For Each objItem in colItems
    If objItem.Model = "VMware Virtual Platform" Then
		objShell.Popup "Running in Virtual Environment, so setting static ip.", 5, "VM Check"
		Return = objShell.Run("cmd.exe /c netsh int ipv4 set address name=""Ethernet0"" static 10.14.104.204 255.255.255.0 10.14.104.1 1", 1, true)
	Else
		objShell.Popup "Not running in Virtual Environment", 5, "VM Check"
	End If
Next