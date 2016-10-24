Param([string]$Phase = "A")
$VerbosePreference = "Continue"
# Give system time to start up and re-connect to vagrant shares.
Start-Sleep -Seconds "3"

If (-not (Test-Path $profile)) { New-item -type file -force $profile }
Import-Module "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\NetSecurity\NetSecurity.psd1"
Import-Module "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\SmbShare\SmbShare.psd1"
Import-Module "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\NetTCPIP\NetTCPIP.psd1"
Import-Module "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\ServerManager\ServerManager.psd1"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
$scriptPath = $myInvocation.MyCommand.Definition

function AddFolder {
    Param ([string]$xmlPath,[string]$nodeName)
    if (!(Test-Path($xmlPath))) {
    [xml]$xml = "<groups><group /></groups>"
    }elseif (!(([xml](type $xmlPath)).groups.HasChildNodes)) {
    [xml]$xml = "<groups><group /></groups>"
    }else{
    [xml]$xml = (type $xmlPath)
    }
    $newGUID = ([guid]::NewGuid())
[xml]$newNode = @"
<group guid="{$newGUID}" enable="True">
    <Name>$nodeName</Name>
</group>
"@
    $xml.groups.AppendChild($xml.ImportNode($newNode.group, $true))
    $xml.save($xmlPath)
}

function Test-RegistryValue {
    param ([string]$Path,[string]$Value)
    try {
    Get-ItemProperty -Path $Path -Name $Value -ErrorAction Stop | Out-Null
    return $true
    } catch {return $false}
}

function InstallChocoApps {
    If (-not (Test-Connection -ComputerName "google.com" -Count 1 -Quiet))
    {
        Write-Host "Internet is down!"
        Exit
    }
    If (-not (Invoke-WebRequest -Uri "https://chocolatey.org/install.ps1" -UseBasicParsing | Invoke-Expression)) {Exit}
    $chocoPath = "$env:SystemDrive\ProgramData\chocolatey\bin\choco.exe"
    Start-Process -FilePath $chocoPath -ArgumentList "feature enable -n=allowGlobalConfirmation" -Wait -NoNewWindow
    Start-Process -FilePath $chocoPath -ArgumentList "feature enable -n=allowEmptyChecksums" -Wait -NoNewWindow
    Start-Process -FilePath $chocoPath -ArgumentList "source add --name=""local"" --source=""$env:SystemDrive\vagrant_data\packages"" --priority=""1""" -Wait -NoNewWindow
    Start-Process -FilePath $chocoPath -ArgumentList "config set --cache-location=""$env:SystemDrive\vagrant_data\cache""" -Wait -NoNewWindow
    Start-Process -FilePath $chocoPath -ArgumentList "install windows-adk-winpe mdt hackfont notepadplusplus 7zip.install sccmtoolkit imagemagick pscx --limitoutput --allowunofficial" -Wait -NoNewWindow

    # Delete ImageMagick desktop shortcut
    Remove-Item -Path "$env:UserProfile\Desktop\ImageMagick Display.lnk" -Force

    # Set hackfont as default for notepad++
    If (Test-Path -Path "$env:WinDir\Fonts\Hack-Regular.ttf") {
    $path = "${env:ProgramFiles(x86)}\Notepad++\stylers.model.xml"
    $xml = [xml](Get-Content $path)
    $node = $xml.NotepadPlus.GlobalStyles.WidgetStyle | ? { $_.name -eq "Global override" }
    $node.fontName = "Hack"
    $node.fontSize = "11"
    $xml.Save($path)
    }

    # Add notepad++ to path
    Start-Process -FilePath "$env:WinDir\System32\setx.exe" -ArgumentList "PATH ""$env:Path;${env:ProgramFiles(x86)}\Notepad++"" /M" -Wait -NoNewWindow
}

function MDTSetup {
    Import-Module "$env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"

    # Create and share DS folder
    New-Item -Path "C:\DeploymentShare" -ItemType directory
    New-SmbShare -Name "DS" -Path "C:\DeploymentShare" -FullAccess Administrators

    # Add MDT local user account
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c net user MDT P@ssw0rd /add" -Wait -NoNewWindow
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c net localgroup Administrators MDT /add" -Wait -NoNewWindow
    Start-Process -FilePath "cmd.exe" -ArgumentList '/c wmic UserAccount where Name="MDT" set PasswordExpires=False' -Wait -NoNewWindow

    # Create DS using MDT PS provider
    new-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$env:SystemDrive\DeploymentShare" -Description "DS" -NetworkPath "\\$env:computername\DS" | add-MDTPersistentDrive

    # Update bootstrap to include MDT account
    $bootstrapPath = "C:\DeploymentShare\Control\Bootstrap.ini"
    if (Test-Path($bootstrapPath)) { Remove-Item $bootstrapPath -Force }
    Add-Content -Path $bootstrapPath -Value "[Settings]`r`nPriority=Default`r`n[Default]`r`nDeployRoot=\\$env:computername\DS" -Force
    Add-Content -Path $bootstrapPath -Value "`r`nSkipBDDWelcome=YES" -Force
    Add-Content -Path $bootstrapPath -Value "`r`nUserDomain=PDEPLOY`r`nUserID=MDT`r`nUserpassword=P@ssw0rd" -Force

    # Use imagemagick to create custom PE wallpaper incl. date
    If (Test-Path "$env:ProgramFiles\imagemagick*") {
    $imagemagick = (dir "$env:ProgramFiles\imagemagick*\magick.exe").FullName
    $datestamp, $architecture = (Get-Date -format "dd-MMM-yyyy HH:mm"), "x64"
    $fontsize, $fontfamily, $fontstyle, $fontcolor = "14", "Tahoma", "Normal", "Blue"
    $convertstring = 'convert "C:\Program Files\Microsoft Deployment Toolkit\Samples\Background.bmp"'+`
    ' -resize "1024x768" -font "'+$fontfamily+'" -style "'+$fontstyle+'" -fill "'+$fontcolor+'" -pointsize "'+$fontsize+`
    '" -draw "text 850,180 '''+$architecture+' @ '+$datestamp+'''" "C:\DeploymentShare\Background.bmp"'
    Start-Process -FilePath $imagemagick -ArgumentList $convertstring -Wait -NoNewWindow
    }

    # Update PE settings.xml
    $path = "$env:SystemDrive\DeploymentShare\Control\Settings.xml"
    $xml = [xml](Get-Content $path)
    $xml.Settings."SupportX86" = "False"
    $xml.Settings."Boot.x64.ScratchSpace" = "512"
    $xml.Settings."Boot.x64.BackgroundFile" = "$env:SystemDrive\DeploymentShare\Background.bmp"
    $xml.Settings."Boot.x64.SelectionProfile" = "Nothing"
    $xml.Save($path)
    # Perform MDT update
    update-MDTDeploymentShare -path "DS001:"

    # Create custom folders in MDT
    $Folders = ("Win 7x86","Win 7x64","Win 10x64")
    ForEach ($a in $Folders ) { AddFolder -xmlPath "$env:SystemDrive\DeploymentShare\Control\ApplicationGroups.xml" -nodeName $a}
    ForEach ($a in $Folders ) { AddFolder -xmlPath "$env:SystemDrive\DeploymentShare\Control\DriverGroups.xml" -nodeName $a}
    ForEach ($a in $Folders ) { AddFolder -xmlPath "$env:SystemDrive\DeploymentShare\Control\OperatingSystemGroups.xml" -nodeName $a}
    $Folders = ("Win 7x86","Win 7x64","Win 10x64","Win 7x86\Deploy","Win 7x64\Deploy","Win 10x64\Deploy","Win 7x86\Capture","Win 7x64\Capture","Win 10x64\Capture","Development")
    ForEach ($a in $Folders ) { AddFolder -xmlPath "$env:SystemDrive\DeploymentShare\Control\TaskSequenceGroups.xml" -nodeName $a}

    # Copy ISO out to host share
    If (Test-Path "$env:SystemDrive\vagrant_data") {
    Copy-Item -Path "$env:SystemDrive\DeploymentShare\Boot\LiteTouchPE_x64.iso" -Destination "$env:SystemDrive\vagrant_data" -Force
    }
}

function DCRoleInstall {
    $SafeModeAdministratorPasswordText = "P@ssw0rd"
    $SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $SafeModeAdministratorPasswordText -Force
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
    Import-Module "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\ADDSDeployment\ADDSDeployment.psd1"
    Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "$env:SystemDrive\Windows\NTDS" -DomainMode "Win2012R2" -DomainName "pdeploy.com" `
     -DomainNetbiosName "pdeploy" -ForestMode "Win2012R2" -InstallDns:$true -LogPath "$env:SystemDrive\Windows\NTDS" -NoRebootOnCompletion:$true `
     -SysvolPath "$env:SystemDrive\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword $SafeModeAdministratorPassword
}

function AddtRoleInstall {
    Add-ADGroupMember "Domain Admins" "vagrant"
    Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools
    Install-WindowsFeature WDS -IncludeManagementTools
}

function AddtRoleConfig {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c wdsutil /initialize-server /reminst:`"$env:SystemDrive\RemoteInstall`"" -Wait -NoNewWindow
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c wdsutil /set-server /answerclients:all" -Wait -NoNewWindow
    Import-Module "$env:WinDir\system32\WindowsPowerShell\v1.0\Modules\DhcpServer\DhcpServer.psd1"
    Add-DhcpServerv4Scope -Name "Bridged" -StartRange "192.168.50.100" -EndRange "192.168.50.250" -SubnetMask "255.255.255.0" -Description "Internal Network"
    Add-DhcpServerInDC
    Restart-Service -DisplayName "Windows Deployment Services Server"
    Import-WdsBootImage -Path "$env:SystemDrive\DeploymentShare\Boot\LitetouchPE_x64.wim"
}

function CallRestart{
    Param ([string]$nextPhase)
    $commandLine = 'powershell.exe -File "'+$scriptPath+'" "'+$nextPhase+'" >> "\vagrant\debug.log" 2>&1'
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Continue Provisioning" -value $commandLine -Force
    Restart-Computer -Force
    Exit
}

function ClearRestart{
    if (Test-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Value "Continue Provisioning") {
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Continue Provisioning"
    }
}

if ($Phase -eq "A") {
    CallRestart -nextPhase "B"
}

if ($Phase -eq "B") {
    ClearRestart
    InstallChocoApps
    MDTSetup
    DCRoleInstall
    CallRestart -nextPhase "C"
}

if ($Phase -eq "C") {
    ClearRestart
    AddtRoleInstall
}

Copy-Item -Path "\vagrant\debug.log" -Destination "\vagrant\complete.log" -Force
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[System.Windows.Forms.MessageBox]::Show("Configuration is complete and ready for use.." , "Status")