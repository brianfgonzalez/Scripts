Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapter" | `
    Where-Object { $_.Name -like "Mobile Broadband Connection*"} | `
    ForEach-Object {
        #Write-Host @($env:SystemDrive + '\Windows\System32\netsh.exe interface ipv4 set subinterface "' + $_.InterfaceIndex + '" mtu=1300 store=persistent')
        Start-Process "$env:SystemDrive\Windows\System32\netsh.exe" @(`
        'interface ipv4 set subinterface "' + $_.InterfaceIndex + '" mtu=1300 store=persistent') -Wait -WindowStyle Minimized
    }

# Command to query installed modems:
# netsh int ipv4 show int