$SSIDList = IMPORT-CSV C:\Temp\SSID.csv

netsh wlan delete profile name=*

FOREACH ($SSIDitem in $SSIDList) 
{
   $SSIDProfile = $SSIDitem.SSID
   (Get-Content C:\Temp\profile.xml) | Foreach-Object {$_ -replace "profileholder", $SSIDProfile} | Set-Content ("C:\Temp\SSID\" + $SSIDProfile + ".xml")        
}
dir c:\temp\SSID\ -recurse -include *.xml | %{netsh wlan add profile filename= $_.FullName}

Remove-Item c:\TEMP\SSID\*