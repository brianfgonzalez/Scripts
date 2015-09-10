$pdfreader = "$env:windir\temp\SumatraPDF.exe"
if (Test-Path $pdfreader) {
    Get-WmiObject -Query "SELECT * From Win32_LogicalDisk WHERE Size > 0 AND NOT DriveType LIKE '4'" |`
    % {
        Write-Host ($_.DeviceID + "\help\")
        Get-ChildItem -Filter "*.pdf" -Force -Path ($_.DeviceID + "\help\")
        } |`
    % {
        Start-Process $pdfreader @('"' + $_.FullName + '"') -NoNewWindow | Out-Null
      }
} else {
    Write-Host "$pdfreader not found.  Can not open help PDF."
}