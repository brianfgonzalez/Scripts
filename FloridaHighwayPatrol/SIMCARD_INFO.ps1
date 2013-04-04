###########################################
##          Matt Soteros 3/8/2013        ##
##    Script to log SIMCard Information  ##
###########################################

# Grab Current Directory
$invocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $invocation.MyCommand.Path

# Get the Comport the Modem is connected to
$comPortNumber = Get-WMIObject win32_potsmodem | where-object {$_.DeviceID -like "USB\VID*"} | foreach {$_.AttachedTo} 

# gets Computername
$Name = $env:COMPUTERNAME
New-ItemProperty HKLM:\Hardware\DESCRIPTION\SIMCARD -Name "ComputerName" -Value "$Name"

# Gets Logged on Username
$User = $env:USERNAME
New-ItemProperty HKLM:\Hardware\DESCRIPTION\SIMCARD -Name "UserName" -Value "$User"

# Creates Registry key for storing SIMCard Information
If(!(Test-path -Path "HKLM:\Hardware\DESCRIPTION\SIMCARD")) {New-Item HKLM:\Hardware\DESCRIPTION\SIMCARD}

# ICCID
$port = new-Object System.IO.Ports.SerialPort $comPortNumber,9600,None,8,one
$port.Open()
$port.Write( "AT" )
$port.Write( "+ICCID" + "`r" )
start-sleep -m 50
$File = $port.ReadExisting() 
$port.Close()
[string]$ICCID = ($file | select-string -Pattern "ICCID:") 
$ICCID = $ICCID.remove(0,18)
$ICCID
New-ItemProperty HKLM:\Hardware\DESCRIPTION\SIMCARD -Name  "ICCID" -Value $ICCID.Remove(20) -Force

# IMSI
$port = new-Object System.IO.Ports.SerialPort $comPortNumber,9600,None,8,one
$port.Open()
$port.Write( "AT" )
$port.Write( "+CIMI" + "`r" )
start-sleep -m 50
$File = $port.ReadExisting() 
$port.Close()
[string]$CIMI= ($file | select-string -Pattern "CIMI") 
$CIMI = $CIMI.remove(0,11) 
$CIMI
New-ItemProperty HKLM:\Hardware\DESCRIPTION\SIMCARD -Name  "IMSI" -Value $CIMI.remove(14) -Force

# IMEI
$port = new-Object System.IO.Ports.SerialPort $comPortNumber,9600,None,8,one
$port.Open()
$port.Write( "AT" )
$port.Write( "+CGSN" + "`r" )
start-sleep -m 50
$File = $port.ReadExisting() 
$port.Close()
[string]$CGSN= ($file | select-string -Pattern "CGSN") 
$CGSN = $CGSN.remove(0,10)
$CGSN
New-ItemProperty HKLM:\Hardware\DESCRIPTION\SIMCARD -Name  "IMEI" -Value $CGSN.remove(16) -Force 

#Device Model
$port = new-Object System.IO.Ports.SerialPort $comPortNumber,9600,None,8,one
$port.Open()
$port.Write( "AT" )
$port.Write( "+CGMM" + "`r" )
start-sleep -m 50
$File = $port.ReadExisting() 
$port.Close()
[string]$CGMM = ($file | select-string -Pattern "CGMM") 
$CGMM = $CGMM.remove(0,10) 
$CGMM
New-ItemProperty HKLM:\Hardware\DESCRIPTION\SIMCARD -Name  "Model" -Value $CGMM.Remove(58) -Force 

# Phone #
$port = new-Object System.IO.Ports.SerialPort $comPortNumber,9600,None,8,one
$port.Open()
$port.Write( "AT" )
$port.Write( "+CNUM" + "`r" )
start-sleep -m 50
$File = $port.ReadExisting() 
$port.Close()
[string]$CNUM = ($file | select-string -Pattern "CNUM:") 
$CNUM = $CNUM.remove(0,19) 
$CNUM 
New-ItemProperty HKLM:\Hardware\DESCRIPTION\SIMCARD -Name  "Phone#" -Value $CNUM.Remove(11) -Force

# Timestamps log file
"$(Get-date -format g)" | Out-File $sCurrentDirectory + "\Simcard.txt" -Append

# Add Logged on Username and Computername
#Add-Content C:\admin\Simcard.txt "`n$name, $User"

# Copies SimCard information to txt file.
Get-ItemProperty "HKLM:\Hardware\DESCRIPTION\SIMCARD" | Out-File $sCurrentDirectory + "\Simcard.txt" -Append