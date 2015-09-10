$oInvocation = (Get-Variable MyInvocation).Value
Set-Location(Split-Path $oInvocation.MyCommand.Path)

Get-WmiObject -Query "SELECT * From Win32_LogicalDisk WHERE Size > 0 AND NOT DriveType LIKE '4'" |`
% { Get-ChildItem -Filter "*.wim" -Force -Path @($_.DeviceID + "\*\Operating Systems\*\previous") -Recurse } |`
% {
    Write-Output "Copying Previously Captured OS..."
	Start-Process "$env:windir\system32\cmd.exe" @('/C robocopy.exe "' + $_.DirectoryName + `
            '" "' + $_.DirectoryName + '\.." /E') -Wait -NoNewWindow | Out-Null
}

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
[Microsoft.VisualBasic.Interaction]::MsgBox("OSes has been reverted to previous state",'OKOnly,Information', "Process Complete") | Out-Null