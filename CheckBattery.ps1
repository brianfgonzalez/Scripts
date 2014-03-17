If ((Get-WmiObject -Query "SELECT * From Win32_Battery").BatteryStatus -ne 2)
{ Write-Host "Please plug in your laptop" }