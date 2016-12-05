Get-ChildItem @("HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", 
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") | `
? { $_.Name.Substring($_.Name.Length-1) -eq '}' } | `
% { New-Object -TypeName psobject -Property @{
    GUID = $_.PSChildName
    Path = $_.Name
    Name = $_.GetValue('DisplayName')
    Uninstall = $_.GetValue('UninstallString')
    Version = $_.GetValue('Version') }
} | Export-Csv -Path "C:\users\briang\Desktop\appguids.csv"
#ft -Property Name,GUID -AutoSize