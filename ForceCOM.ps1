# Author: Alfred Tolentino <alfred.tolentino@us.panasonic.com>
# Changelog:
# 7/11/2016 - BFG
#	- Changed query to use "Caption" instead of "Name".
#	- Added code to strip " (COM[0-9]{1,2})" from device name using -replace.
#	- Created block of code to update ComDB to set target COMPort to "In-Use".
#	- Added permission change calls inside of function due to issue with permissions editing the Reg.
#	- Replaced regini.exe with SetACL.exe, which worked consistantly for reg perm changes.

#$DeviceName = "Communications Port (COM3)"
#$DeviceName = "u-blox Virtual COM Port"
$DeviceName = "Sierra Wireless NMEA Port"
$ComPort = "COM3"


#Grab script directory
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
#Add Administrators to "ENUM" and "COM NAME Arbiter" key parents
Start-Process -FilePath "$scriptPath\SetACL.exe" -ArgumentList @('-on "HKEY_LOCAL_MACHINE\System\CurrentControlSet\ENUM" -ot reg -actn setowner -ownr "n:Administrators"') -Wait -WindowStyle Minimized
Start-Process -FilePath "$scriptPath\subinacl.exe" -ArgumentList @('/subkeyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum" /grant=administrators=f /setowner=administrators') -Wait -WindowStyle Minimized
Start-Process -FilePath "$scriptPath\subinacl.exe" -ArgumentList @('/subkeyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\COM NAME Arbiter" /grant=administrators=f /setowner=administrators') -Wait -WindowStyle Minimized

function Change-ComPort {

 	Param ($Name,$NewPort)

 	#Queries WMI for Device Caption
	#$WMIQuery = 'Select * from Win32_PnPEntity where Descripition = "' + $Name + '"'
	$Device = Get-WmiObject -Class Win32_PnPEntity | Where-Object { $_.Caption -like "*$($Name)*" } 

 	#Execute only if device is present
	if ($Device) {
		
        #Give Permissions to Administrators for desired ENUM key
        Start-Process "$scriptPath\SetACL.exe" @('-on "HKEY_LOCAL_MACHINE\System\CurrentControlSet\ENUM\'+$Device.DeviceID+'" -ot reg -actn setowner -ownr n:Administrators') -Wait -WindowStyle Minimized
        Start-Process "$scriptPath\subinacl.exe" @('/subkeyreg "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\'+$Device.DeviceID+'" /grant=administrators=f /setowner=administrators') -Wait -WindowStyle Minimized
        
		#Get current device info
		$DeviceKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\" + $Device.DeviceID
		$PortKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\" + $Device.DeviceID + "\Device Parameters"
		$Port = get-itemproperty -path $PortKey -Name PortName
		$OldPort = [convert]::ToInt32(($Port.PortName).Replace("COM",""))
		
		#Set new port and update Friendly Name
        $Name = $Name -replace " \(COM[0-9]{1,2}\)", ""
		$FriendlyName = $Name + " (" + $NewPort + ")"
		New-ItemProperty -Path $PortKey -Name "PortName" -PropertyType String -Value $NewPort -Force
		New-ItemProperty -Path $DeviceKey -Name "FriendlyName" -PropertyType String -Value $FriendlyName -Force

 		#Set old Com Port as available
		$Byte = ($OldPort - ($OldPort % 8))/8
		$Bit = 8 - ($OldPort % 8)
		if ($Bit -eq 8) {
			$Bit = 0 
			$Byte = $Byte - 1
		}
		$ComDB = get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB
		$ComBinaryArray = ([convert]::ToString($ComDB.ComDB[$Byte],2)).ToCharArray()
		while ($ComBinaryArray.Length -ne 8) {
			$ComBinaryArray = ,"0" + $ComBinaryArray
		}
        #Flip bit to 0 for Available
		$ComBinaryArray[$Bit] = "0"
		$ComBinary = [string]::Join("",$ComBinaryArray)
		$ComDB.ComDB[$Byte] = [convert]::ToInt32($ComBinary,2)
		Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB -Value ([byte[]]$ComDB.ComDB)

 		#Set the new Com Port from ComDB is set to InUse
		$NewPort = $NewPort.Replace("COM","")
		$Byte = ($NewPort - ($NewPort % 8))/8
		$Bit = 8 - ($NewPort % 8)
		if ($Bit -eq 8) { 
			$Bit = 0 
			$Byte = $Byte - 1
		}
		$ComDB = get-itemproperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB
		$ComBinaryArray = ([convert]::ToString($ComDB.ComDB[$Byte],2)).ToCharArray()
		while ($ComBinaryArray.Length -ne 8) {
			$ComBinaryArray = ,"0" + $ComBinaryArray
		}
        #Flip bit to 1 for In-Use
		$ComBinaryArray[$Bit] = "1"
		$ComBinary = [string]::Join("",$ComBinaryArray)
		$ComDB.ComDB[$Byte] = [convert]::ToInt32($ComBinary,2)
		Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\COM Name Arbiter" -Name ComDB -Value ([byte[]]$ComDB.ComDB)
		
	}
}

Change-ComPort $DeviceName $ComPort
reg.exe load HKLM\ImportedHive "C:\Users\Default\NTUser.DAT"
reg.exe import "$scriptPath\SetGPSViewerToCOM3.reg"
reg.exe unload HKLM\ImportedHive