if (Test-Path "$env:systemdrive\program files (x86)") {
    $tracer = "$env:windir\system32\cmtrace_x64.exe"
	Start-Process "$env:windir\system32\cmd.exe" @('/c assoc .log=logfile') -Wait -NoNewWindow | Out-Null
	Start-Process "$env:windir\system32\cmd.exe" @('/c ftype logfile=%SystemRoot%\system32\cmtrace_x64.exe %%1') -Wait -NoNewWindow | Out-Null
} else {
    $tracer = "$env:windir\system32\cmtrace_x86.exe"
	Start-Process "$env:windir\system32\cmd.exe" @('/c assoc .log=logfile') -Wait -NoNewWindow | Out-Null
	Start-Process "$env:windir\system32\cmd.exe" @('/c ftype logfile=%SystemRoot%\system32\cmtrace_x86.exe %%1') -Wait -NoNewWindow | Out-Null
}
if (Test-Path $tracer) {
    Get-WmiObject -Query "SELECT * From Win32_LogicalDisk WHERE Size > 0 AND NOT DriveType LIKE '4'" |`
    % { Get-ChildItem -Filter "bdd.log" -Force -Path ($_.DeviceID + "\MININT\SMSOSD\OSDLOGS"),($_.DeviceID + "\Windows\Temp\DeploymentLogs") -Recurse } |`
    % { Start-Process $tracer @($_.FullName) -NoNewWindow | Out-Null }
} else {
    Write-Host "$tracer not found.  Can not open BDD."
}