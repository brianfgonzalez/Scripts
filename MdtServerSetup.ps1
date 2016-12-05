[CmdletBinding()]
Param([string]$Phase = 'A',[string]$CompName = 'MDT2013U201')
# ============================================================================================
#Script installs MDT 2013 Update 2 release (6.3.8330.1000)
# & ADK for Windows 10 (10.1.14393.0)
# ============================================================================================
#Values that can be changed
$deployRoot = "$env:SystemDrive\DeploymentShare" #Specify DeploymentShare local folder path
$deployshareName = "DS" #Specify desired share name
$desiredSecurePassword = 'P@ssw0rd' #Specify Desired secure password for Administrator and AD recovery
$DomainName = "PDEPLOY" #NetBIOS name for Domainname, will be suffixed with .com
# ============================================================================================
#Populate transcript log file path
$transcriptPath = "$env:SystemDrive\tmp\debug.log"

#Populate parent folder of ps modules
$psmodulePath = "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules"

#Begin populating transcript log file
$ErrorActionPreference = 'SilentlyContinue'
$null = Stop-Transcript
$ErrorActionPreference = 'Continue'
Start-Transcript -Path $transcriptPath -Append -NoClobber

#Load common powershell modules
Import-Module -Name "$psmodulePath\NetSecurity\NetSecurity.psd1"
Import-Module -Name "$psmodulePath\SmbShare\SmbShare.psd1"
Import-Module -Name "$psmodulePath\NetTCPIP\NetTCPIP.psd1"
Import-Module -Name "$psmodulePath\ServerManager\ServerManager.psd1"

#Populate full path of script file
$scriptPath = $myInvocation.MyCommand.Definition

#Specify chocoPath
$chocofilePath = "$env:ProgramData\chocolatey\choco.exe"

#Function to add folders into MDT Deployment Shares..
function AddFolder 
{
  Param ([Parameter(Mandatory=$true)][string]$xmlPath,[Parameter(Mandatory=$true)][string]$nodeName)
  #Check if target XML exist
  if (!(Test-Path -Path $xmlPath)) 
  {
    #If not auto-generated, create a fresh xml
    [xml]$xml = '<groups></groups>'
  }
  else
  {
    #pull XML content
    [xml]$xml = (Get-Content -Path $xmlPath)
  }
  #Add new content
  $newGUID = ([guid]::NewGuid())
  [xml]$newNode = @"
<group guid="{$newGUID}" enable="True">
  <Name>$nodeName</Name>
</group>
"@
  $xml.Item('groups').AppendChild($xml.ImportNode($newNode.group, $true))
  $xml.save($xmlPath)
}

#Function to log and call external EXEs
function CallExternalApplication
{
  Param ([Parameter(Mandatory=$true)][string]$filePath,[Parameter(Mandatory=$true)][string]$argumentString)
  Write-Host "Attempting to run: $filePath $argumentstring"
  If (-not (Test-Path -Path $filePath))
  {
    Write-Host "$filePath not found."
    return $false
  }
  Start-Process -FilePath $filePath -ArgumentList $argumentstring -Wait -NoNewWindow -Verbose
}

#Function to install chocolately and use it to install several applications
function InstallChocoApps 
{
  #Check if chocolately is already installed
  If (-not (Test-Path -Path $chocofilePath)) 
  {
    #Check internet connection
    If (-not (Test-Connection -ComputerName 'google.com' -Count 1 -Quiet)) 
    {
      #Look for localized install of chocolately
      If (Get-ChildItem -Path "$env:SystemDrive\chocopkgs\chocolatey*\tools") 
      {
        #Call chocolately local install
        . (Get-ChildItem -Path "$env:SystemDrive\chocopkgs\chocolatey*\tools\chocolateyInstall.ps1").FullName
      }
      else 
      {
        #No localized choco install found, so we must prompt user to get connected and re-run script.
        $promptText = ('Internet Connection not found AND local choco pkg not found in '+$env:SystemDrive+'\chocopkgs'+`
        '`r`nRe-run script: c:\tmp\script.ps1')
        $null = Add-Type -AssemblyName System.Windows.Forms
        $null = [Windows.Forms.MessageBox]::Show($promptText , 'Fatal Error')
        ClearRestart
        Exit
      }
    }
    else 
    {
      #No localized choco install found, so installing using online ps1
      Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1' -UseBasicParsing | Invoke-Expression -Verbose
    }
  }
  else 
  {
    Write-Host -Message 'Choco already installed... skipping installation..'
  }
  
  #Restart transcript as chocoalately init kills transcript
  $ErrorActionPreference = 'SilentlyContinue'
  $null = Stop-Transcript
  $ErrorActionPreference = 'Continue'
  Start-Transcript -Path $transcriptPath -Append -NoClobber -Force
  
  #Configure choco install settings
  $carg = 'feature enable -n=allowGlobalConfirmation'
  CallExternalApplication -filePath $chocofilePath -argumentString $carg 
  $carg = 'source add --name="local" --source="'+$env:SystemDrive+'\vagrant" --priority="1"'
  CallExternalApplication -filePath $chocofilePath -argumentString $carg
  
  #Install Windows ADK for Windows 10 10.1.14393.0 using local source (if avail.)
  $carg = 'install windows-adk-winpe --version 10.1.14393.0 --debug --allowunofficial --confirm'
  CallExternalApplication -filePath $chocofilePath -argumentString $carg
  
  #Install MDT 2013 update 2 using local source (if avail.)
  $carg = 'install mdt --version 6.3.8330.1000 --debug --allowunofficial --confirm'
  CallExternalApplication -filePath $chocofilePath -argumentString $carg
 
  #Install SCCM Toolkit 2012 R2 using local source  (if avail.)
  $carg = 'install sccmtoolkit --version 5.0.7958.1000 --debug --allowunofficial --confirm'
  CallExternalApplication -filePath $chocofilePath -argumentString $carg
  
  #Install other useful applications from interweb
  $carg = 'install hackfont notepadplusplus 7zip.install imagemagick --debug --confirm'
  CallExternalApplication -filePath $chocofilePath -argumentString $carg
  
  # Delete ImageMagick desktop shortcut
  If (Test-Path -Path "$env:UserProfile\Desktop\ImageMagick Display.lnk") 
  {
    Remove-Item -Path "$env:UserProfile\Desktop\ImageMagick Display.lnk" -Force -Verbose
  }

  # Set hackfont as default for notepad++
  If ((Test-Path -Path "$env:WinDir\Fonts\Hack-Regular.ttf") -and
  (Test-Path -Path "${env:ProgramFiles(x86)}\Notepad++\stylers.model.xml")) 
  {
    $path = "${env:ProgramFiles(x86)}\Notepad++\stylers.model.xml"
    $xml = [xml](Get-Content -Path $path)
    $node = $xml.NotepadPlus.GlobalStyles.WidgetStyle | Where-Object -FilterScript {
      $_.name -eq 'Global override' 
    }
    $node.fontName = 'Hack'
    $node.fontSize = '11'
    $xml.Save($path)
  }

  # Add notepad++ to path
  If (Test-Path -Path "${env:ProgramFiles(x86)}\Notepad++\stylers.model.xml") 
  {
    $carg = 'PATH "'+$env:Path+';'+${env:ProgramFiles(x86)}+'\Notepad++" /M'
    CallExternalApplication -filePath "$env:WinDir\System32\setx.exe" -argumentString $carg
  }

  # Add cmtrace to path
  If (Test-Path -Path "${env:ProgramFiles(x86)}\ConfigMgr 2012 Toolkit R2\ClientTools\CMTrace.exe") 
  {
    $carg = 'PATH "'+$env:Path+';'+${env:ProgramFiles(x86)}+'\ConfigMgr 2012 Toolkit R2\ClientTools\" /M'
    CallExternalApplication -filePath "$env:WinDir\System32\setx.exe" -argumentString $carg
  }
}

function MDTSetup 
{
  #Populate CustomSettings.ini rules content
  $customSettings = @"
;Go here for help on rules: https://technet.microsoft.com/en-us/library/dn781091.aspx
[Settings]
Priority=ProcessFirst,Default
Properties=MyCustomProperty,SpecialDate
[ProcessFirst]
SpecialDate=#DatePart("M",Now) & DatePart("D",Now) & DatePart("YYYY",Now)#

[Default]
;_SMSTSOrgName=Company Name
;_SMSTSPackageName=Sub-Progress Text...

OSInstall=Y
SkipProductKey=YES
SkipSupervisorPass=YES

SkipAdminPassword=YES
AdminPassword=P@ssw0rd

SkipSummary=YES

SkipDomainMembership=YES
JoinWorkgroup=WORKGROUP

SkipUserData=YES
UserDataLocation=NONE

SkipComputerBackup=YES
ComputerBackupLocation=NONE
SkipBitLocker=YES
BDEInstallSuppress=YES
SkipLocaleSelection=YES
SkipTimeZone=YES
KeyboardLocale=en-US
UserLocale=en-US
UILanguage=en-US
TimeZone=035
TimeZoneName=Eastern Standard Time
ApplyGPOPack=NO

SkipCapture=YES
BackupShare=\\$CompName\$deployshareName\Captures
BackupDir=%SpecialDate%.wim
;ProductKey=XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
"@
  #Populate Bootstrap.ini rules content
  $bsSettings = @"
[Settings]
Priority=Default

[Default]
DeployRoot=\\$CompName\$deployshareName
SkipBDDWelcome=YES

UserDomain=$DomainName
UserID=MDT
Userpassword=$desiredSecurePassword
"@
  #Import MDT module
  If (Test-Path -Path "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1")
  {
    Import-Module -Name "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
  }
  else
  {
    #Prompt user that the MDT install failed.
    $null = Add-Type -AssemblyName System.Windows.Forms
    $null = [Windows.Forms.MessageBox]::Show(
    "MDT Install failed, so script is exiting..logpath: $env:SystemDrive\tmp\script.log" , 'Fatal Error')
    ClearRestart
    Exit
  }

  #Create DeploymentShare folder
  New-Item -Path $deployRoot -ItemType Directory -Force -Verbose
  #Create DS network share
  New-SmbShare -Name $deployshareName -Path $deployRoot -FullAccess Administrators -Verbose

  #Create MDT local user account
  $carg = 'user MDT "'+$desiredSecurePassword+'" /add'
  CallExternalApplication -filePath "$env:WinDir\System32\net.exe" -argumentString $carg
  #Add MDT account to Administrators group
  $carg = 'localgroup Administrators MDT /add'
  CallExternalApplication -filePath "$env:WinDir\System32\net.exe" -argumentString $carg
  #Set MDT account password to never expire
  $carg = '/c wmic UserAccount where Name="MDT" set PasswordExpires=False'
  CallExternalApplication -filePath "$env:WinDir\System32\cmd.exe" -argumentString $carg

  #Create DS using MDT PS provider
  New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root $deployRoot -Description "DS" `
    -NetworkPath "\\$CompName\$deployshareName" | add-MDTPersistentDrive -Verbose

  #Update bootstrap to include MDT account
  $bsPath = "$deployRoot\Control\Bootstrap.ini"
  $csPath = "$deployRoot\Control\CustomSettings.ini"
  if (Test-Path -Path $bsPath) 
  {
    Remove-Item -Path $bsPath -Force
  }
  if (Test-Path -Path $csPath) 
  {
    Remove-Item -Path $csPath -Force
  }
  Set-Content -Path $bsPath -Value ($bsSettings -replace "\n", "`r`n") -Force
  Set-Content -Path $csPath -Value ($customSettings -replace "\n", "`r`n") -Force

  #Use imagemagick to create custom PE wallpaper incl. Date & PE arch
  If (Test-Path -Path "$env:ProgramFiles\imagemagick*") 
  {
    $imagemagick = (Get-ChildItem -Path "$env:ProgramFiles\imagemagick*\magick.exe").FullName
    $datestamp = (Get-Date -Format 'dd-MMM-yyyy HH:mm')
    $architecture = "x64"
    $fontsize = "14"
    $fontfamily = "Tahoma"
    $fontstyle = "Normal"
    $fontcolor = "Blue"
    $carg = 'convert "'+$env:ProgramFiles+'\Microsoft Deployment Toolkit\Samples\Background.bmp"'+`
    ' -resize "1024x768" -font "'+$fontfamily+'" -style "'+$fontstyle+'" -fill "'+$fontcolor+'" -pointsize "'+$fontsize+`
    '" -draw "text 850,180 '''+$architecture+' @ '+$datestamp+'''" "'+$env:SystemDrive+'\DeploymentShare\Background.bmp"'
    CallExternalApplication -filePath $imagemagick -argumentString $carg
  }

  #Update PE settings.xml
  $path = "$deployRoot\Control\Settings.xml"
  $xml = [xml](Get-Content -Path $path)
  $xml.Settings."SupportX86" = "False"
  $xml.Settings."Boot.x64.ScratchSpace" = "512"
  #Set custom background image (if avail.)
  If (Test-Path -Path "$deployRoot\Background.bmp")
  {
    $xml.Settings."Boot.x64.BackgroundFile" = "$deployRoot\Background.bmp"
  }
  $xml.Settings."Boot.x64.SelectionProfile" = "Nothing"
  $xml.Save($path)

  #Perform MDT update
  Update-MDTDeploymentShare -Path "DS001:" -Verbose

  #Create custom folders in MDT
  $Folders = ("Adobe", "Microsoft", "Microsoft\Office", "Oracle", "Panasonic", "Sierra", "Win 7x86", "Win 7x64", "Win 10x64")
  ForEach ($a in $Folders ) 
  {
    AddFolder -xmlPath "$deployRoot\Control\ApplicationGroups.xml" -nodeName $a
  }
  $Folders = ("Win 7x86", "Win 7x64", "Win 10x64", "Win 7x86\SF", "Win 7x64\SF", "Win 10x64\SF")
  ForEach ($a in $Folders ) 
  {
    AddFolder -xmlPath "$deployRoot\Control\OperatingSystemGroups.xml" -nodeName $a
  }
  $Folders = ("Win 7x86", "Win 7x64", "Win 10x64 (incl. PE Drivers)")
  ForEach ($a in $Folders ) 
  {
    AddFolder -xmlPath "$deployRoot\Control\DriverGroups.xml" -nodeName $a
  }
  $Folders = ("Win 7x86", "Win 7x64", "Win 10x64", "Win 7x86\Deploy", "Win 7x64\Deploy", "Win 10x64\Deploy", "Win 7x86\Capture", `
  "Win 7x64\Capture", "Win 10x64\Capture", "Development")
  ForEach ($a in $Folders ) 
  {
    AddFolder -xmlPath "$deployRoot\Control\TaskSequenceGroups.xml" -nodeName $a
  }

  #Populate Operating System\Catalog folder (if interweb connection avail)
  If (Test-Connection -ComputerName "google.com" -Count 1 -Quiet)
  {
    $catfolderPath = "$deployRoot\Catalogs"
    New-Item -Path $catfolderPath -ItemType Directory -Verbose -Force
    Invoke-WebRequest -Uri 'https://github.com/boxcutter/windows/raw/master/wsim/win7/x64/install_Windows%207%20ENTERPRISE.clg' `
    -OutFile "$catfolderPath\Win7x64Ent.clg" -Verbose
    Invoke-WebRequest -Uri 'https://github.com/boxcutter/windows/raw/master/wsim/win7/x64/install_Windows%207%20PROFESSIONAL.clg' `
    -OutFile "$catfolderPath\Win7x64Pro.clg" -Verbose
    Invoke-WebRequest -Uri 'https://github.com/boxcutter/windows/raw/master/wsim/win7/x86/install_Windows%207%20ENTERPRISE.clg' `
    -OutFile "$catfolderPath\Win7x86Ent.clg" -Verbose
    Invoke-WebRequest -Uri 'https://github.com/boxcutter/windows/raw/master/wsim/win7/x86/install_Windows%207%20PROFESSIONAL.clg' `
    -OutFile "$catfolderPath\Win7x86Pro.clg" -Verbose
    Invoke-WebRequest -Uri 'https://github.com/boxcutter/windows/raw/master/wsim/wineval/win10/x64/install_Windows%2010%20Enterprise%20Evaluation.clg' `
    -OutFile "$catfolderPath\Win10x64Ent.clg" -Verbose
  }

  # Copy ISO out to host share
  If (Test-Path -Path "$env:SystemDrive\vagrant") 
  {
    Copy-Item -Path "$deployRoot\Boot\LiteTouchPE_x64.iso" -Destination "$env:SystemDrive\vagrant\MDTBootx64.iso" -Force -Verbose
  }
}

function DCRoleInstall 
{
  $SMAdminPassTxt = $desiredSecurePassword
  $SMAdminPass = ConvertTo-SecureString -AsPlainText -String $SMAdminPassTxt -Force
  Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
  Import-Module -Name "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\ADDSDeployment\ADDSDeployment.psd1"
  Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "$env:SystemDrive\Windows\NTDS" `
    -DomainMode "Win2012R2" -DomainName "$DomainName.com" -DomainNetbiosName $DomainName -ForestMode "Win2012R2" `
    -InstallDns:$true -LogPath "$env:SystemDrive\Windows\NTDS" -NoRebootOnCompletion:$true `
    -SysvolPath "$env:SystemDrive\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword $SMAdminPass -Verbose
}

function DHCPWDSRoleInstall 
{
  #Add MDT user account to "Domain Admins" group. (no longer needed)
  #Add-ADGroupMember 'Domain Admins' 'MDT' -Verbose

  #Install DHCP role with tools
  Install-WindowsFeature -Name "DHCP" -IncludeManagementTools -Verbose

  #Install WDS role with tools
  Install-WindowsFeature WDS -IncludeManagementTools -Verbose
}

function AddtRoleConfig 
{
  #Use wdsutil to initialize server
  $carg = '/initialize-server /reminst:"'+$env:SystemDrive+'\RemoteInstall"'
  CallExternalApplication -filePath "$env:WinDir\System32\wdsutil.exe" -argumentString $carg
  
  #Configure WDS to accept all requests
  $carg = "/set-server /answerclients:all"
  CallExternalApplication -filePath "$env:WinDir\System32\wdsutil.exe" -argumentString $carg
  
  #Import DHCP powershell module
  Import-Module -Name "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\DhcpServer\DhcpServer.psd1"
  
  #Create 50.100 - 50.200 scope
  Add-DhcpServerv4Scope -Name "Bridged" -StartRange "192.168.50.100" -EndRange "192.168.50.250" `
  -SubnetMask "255.255.255.0" -Description "Internal Network" -Verbose
  
  #Authorize DHCP in AD
  Add-DhcpServerInDC -Verbose
  
  #Restart the WDS server to make sure it starts
  Restart-Service -DisplayName "Windows Deployment Services Server" -Verbose
  
  #Import the MDT Litetouch WIM (if avail.)
  If (Test-Path -Path "$deployRoot\Boot\LitetouchPE_x64.wim")
  {
    Import-WdsBootImage -Path "$deployRoot\Boot\LitetouchPE_x64.wim" -Verbose
  }
}

function CallRestart
{
  Param ([Parameter(Mandatory=$true)][string]$nextPhase)
  
  #Create batch in StartUp folder for All Users and pass nextPhase argument to powershell script
  $path = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Continue.bat"
  'powershell.exe -File "'+$scriptPath+'" "'+$nextPhase+'"' | Out-File -FilePath $path -Force -Encoding 'default'
  
  #Set up AdminAutoLogon to occur with local Administrator account
  $winlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
  New-ItemProperty -Path  $winlogonPath -Name "AutoAdminLogon" -Value "1" -PropertyType String -Force -Verbose
  New-ItemProperty -Path  $winlogonPath -Name "DefaultUsername" -Value "Administrator" -PropertyType String -Force -Verbose
  New-ItemProperty -Path  $winlogonPath -Name "DefaultPassword" -Value $desiredSecurePassword -PropertyType String -Force -Verbose
  
  #Stop transcript
  $null = Stop-Transcript
  
  #Initiate a foreced restart
  Restart-Computer -Force
  Exit
}

function ClearRestart
{
  #Delete the batch file from the StartUp folder (if exist)
  $path = "$env:SystemDrive\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\Continue.bat"
  if (Test-Path -Path $path)
  {
    Remove-Item -Path $path -Force -Verbose
  }
  
  #Clear AdminAutoLogon entries in registry
  $winlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
  New-ItemProperty -Path  $winlogonPath -Name "AutoAdminLogon" -Value "0" -PropertyType String -Force -Verbose
  New-ItemProperty -Path  $winlogonPath -Name "DefaultUsername" -Value "0" -PropertyType String -Force -Verbose
  New-ItemProperty -Path  $winlogonPath -Name "DefaultPassword" -Value "0" -PropertyType String -Force -Verbose
}

#MAIN Processing, using $Phase argument with switch statement
switch ($Phase)
{
  "A"
  {
    #ONLY Windows session with \vagrant mapped
    Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False -Verbose
    $carg = 'user administrator "'+$desiredSecurePassword+'" /active:yes'
    CallExternalApplication -filePath "$env:WinDir\System32\net.exe" -argumentString $carg

    #Load DEFAULT hive
    $carg = 'load HKLM\ImportedHive "'+$env:SystemDrive+'\Users\Default\NTUSER.DAT"'
    CallExternalApplication -filePath "$env:WinDir\System32\reg.exe" -argumentString $carg
    $explorerRegPath = "Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    #Do not hide extensions for known file types
    New-ItemProperty -Path  "HKCU:\$explorerRegPath" -Name "HideFileExt" -Value "0" -PropertyType DWORD -Force -Verbose
    New-ItemProperty -Path  "HKLM:\ImportedHive\$explorerRegPath" -Name "HideFileExt" -Value "0" -PropertyType DWORD -Force -Verbose
    #Show Hidden Folders and Files
    New-ItemProperty -Path  "HKCU:\$explorerRegPath" -Name "Hidden" -Value "1" -PropertyType DWORD -Force -Verbose
    New-ItemProperty -Path  "HKLM:\ImportedHive\$explorerRegPath" -Name "Hidden" -Value "1" -PropertyType DWORD -Force -Verbose
    #Unload DEFAULT hive
    $carg = "unload HKLM\ImportedHive"
    CallExternalApplication -filePath "$env:WinDir\System32\reg.exe" -argumentString $carg

    #Install chocolately, adk, mdt, sccmtoolkit, and optionals
    InstallChocoApps

    #Create deployment share and perform initial update and folder creations
    MDTSetup
	
	#Rename the computer
	Rename-Computer -NewName $CompName

    #Call restart, which will occur with local Administrator account
    CallRestart -nextPhase 'B'
  }
  "B"
  {
    If (Test-Path -Path "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1")
    {
      Import-Module -Name "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
    }
    else
    {
      #Prompt user that the MDT install failed.
      $null = Add-Type -AssemblyName System.Windows.Forms
      $null = [Windows.Forms.MessageBox]::Show(
      "MDT Install failed, so script is exiting..logpath: $env:SystemDrive\tmp\script.log" , 'Fatal Error')
      ClearRestart
      Exit
    }
  
    #Open DS under Administrator credential
    New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root $deployRoot -Description "DS" `
      -NetworkPath "\\$CompName\$deployshareName" | add-MDTPersistentDrive -Verbose

    #Call Install Domain Controller function
    DCRoleInstall	
    
    #Call restart to allow DC install to complete
    CallRestart -nextPhase 'C'
  }
  "C"
  {
    #Install DHCP and WDS roles
    DHCPWDSRoleInstall
    
    #Call restart to allow role installs to complete
    CallRestart -nextPhase 'D'
  }
  "D"
  {
    #Final configurations of DHCP and WDS roles and copy routine of ISO to tmp folder
    AddtRoleConfig
  }
}

#Clean up script
ClearRestart

#Copy transcript out to Administrator's desktop
Copy-Item -Path "$env:SystemDrive\tmp\debug.log" -Destination "$env:UserProfile\Desktop\complete.log" -Force -Verbose

#Prompt user that script is complete
$null = Add-Type -AssemblyName System.Windows.Forms
$null = [Windows.Forms.MessageBox]::Show(
"Configuration is complete and ready for use..logpath: $env:UserProfile\Desktop\complete.log" , 'Status')