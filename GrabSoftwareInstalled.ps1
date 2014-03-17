Get-WmiObject -Class Win32_Product | `
	Sort-Object Name | `
	Select-Object Name, Version | `
	Out-File "D:\SoftwareListing.csv"