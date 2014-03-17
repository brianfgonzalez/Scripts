	Set oWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set oOperatingSystems = oWMIService.ExecQuery ("Select * from Win32_OperatingSystem")
	For Each oTmp in oOperatingSystems
		Wscript.Echo "Version: " & oTmp.Version
	Next