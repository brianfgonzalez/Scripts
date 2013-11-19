# Remove Old Drive
Get-ChildItem "C:\Windows\inf\*.inf" |`
    Select-String "slabvcp" |
    ForEach{
        Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList @("/C PNPUTIL -f -d " + $_.FileName) -Wait -WindowStyle Hidden
    }
# Install New Driver (slabvcp.inf/6.6.1.0)
Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList @("/C PNPUTIL -i -a CP210x_VCP_Windows\slabvcp.inf") -Wait -WindowStyle Hidden