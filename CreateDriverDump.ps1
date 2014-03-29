Get-WmiObject -Query "SELECT * FROM Win32_PnpSignedDriver" | `
	?{$_.DriverVersion.Length -gt 0} | `
	%{ Write-Output @($_.DeviceName + "," + $_.DriverVersion) } | `
    Sort-Object -Property $_.DeviceName | `
	Out-File F:\WendysDriverListing.txt