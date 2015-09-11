<#
Version: 1.1
ChangeLog:
	- September 10, 2015 : First revision of script.
    - Moved function code above function call.
    1.1
    - Switched to using [System.IO.DriveInfo]::getdrives() instead of gwmi
#>
function fReRunPrompt{
$sRet = [Microsoft.VisualBasic.Interaction]::MsgBox("Would you like to rerun the script?",'YesNo,Question', "Rerun script prompt")
If ($sRet -eq "Yes")
{
    fMain
}
}


function fMain
{

#$ErrorActionPreference = "SilentlyContinue"
#trap {"Error found: $_" | Out-File "F:\CollectLogs.log"}

# Locate USB media drive letter
#######################################################################################################################################################
try
{
    $oAllUSBDrive = ([System.IO.DriveInfo]::getdrives() | ?{ $_.DriveType -eq "Removable"} | Sort-Object -Descending TotalSize)[0]
    if ($oAllUSBDrive -eq $null)
    {
        $oAllUSBDrive = ([System.IO.DriveInfo]::getdrives() | ?{ $_.DriveType -eq "Removable"} | Sort-Object -Descending TotalSize)
    }
    $sUSBDriveLetter = $oAllUSBDrive.Name
}
catch
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
    [Microsoft.VisualBasic.Interaction]::MsgBox("An error occurred when attempting to locate USB drive.",'OKOnly,Exclamation', "Error encountered") | Out-Null
    fReRunPrompt
    Exit
}

# Locate Local HDD drive letter (100GB+)
#######################################################################################################################################################
try
{
    $oLocalLargestHDD = ([System.IO.DriveInfo]::getdrives() | ?{ $_.DriveType -eq "Fixed"} | Sort-Object -Descending TotalSize)[0]
    If ($oLocalLargestHDD.TotalSize -gt 100000000)
    {
        $sHDDDriveLetter = $oLocalLargestHDD.Name
    } else {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
        [Microsoft.VisualBasic.Interaction]::MsgBox("HDD is NOT 100GB, so there is no SYSTEM partition!",'OKOnly,Exclamation', "Error encountered") | Out-Null
        fReRunPrompt
        Exit
    }
}
catch
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
    [Microsoft.VisualBasic.Interaction]::MsgBox("An error occurred when attempting to locate a HDD drive.",'OKOnly,Exclamation', "Error encountered") | Out-Null
    fReRunPrompt
    Exit
}

# Create folder on USB media named with DATE and TIME stamp information
#######################################################################################################################################################
$sDateFormat = (Get-Date -format "yyyy-M-d_HHmm")
$sLogFolderPath = "{0}{1}" -f $sUSBDriveLetter, $sDateFormat
New-Item -type Directory -path $sLogFolderPath -force

# Copy all Windows or Deployment related log files on local HDD
try
{
    $oLocalLargestHDD = ([System.IO.DriveInfo]::getdrives() | ?{ $_.DriveType -eq "Fixed"} | Sort-Object -Descending TotalSize)[0]
    If ($oLocalLargestHDD.TotalSize -gt 100000000)
    {
        $sHDDDriveLetter = $oLocalLargestHDD.Name
    } else {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
        [Microsoft.VisualBasic.Interaction]::MsgBox("HDD is NOT 100GB, so there is no SYSTEM partition!",'OKOnly,Exclamation', "Error encountered") | Out-Null
        fReRunPrompt
        Exit
    }
}
catch
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
    [Microsoft.VisualBasic.Interaction]::MsgBox("An error occurred when attempting to locate a HDD drive.",'OKOnly,Exclamation', "Error encountered") | Out-Null
    fReRunPrompt
    Exit
}

# Copy log files into created Directory on USB drive
#######################################################################################################################################################
# Function to reuse search and copy
function fSearchAndCopy($aDirectories)
{
    $sInt=0
    foreach ($sDirectory in $aDirectories)
    {
        $sDirectory = "{0}{1}" -f $sHDDDriveLetter, $sDirectory
        $sMsg = "Copying {0}" -f $sDirectory
        Write-Host $sMsg
        if ((Test-Path $sDirectory) -eq $true)
        {
            $sInt = $sInt + 1
            $sDestinationDirectory = "$sLogFolderPath\$sInt"
            Write-Host $sDirectory
            New-Item -type Directory -path "$sDestinationDirectory" -force
            Copy-Item -Path "$sDirectory\*" -Destination "$sDestinationDirectory" -Force -Recurse
            Add-Content "$sDestinationDirectory\OriginalDirectory.txt" $sDirectory
        }
    }
}

# Populate Directories Array
$aDirectories =
    @("Windows\Temp\DeploymentLogs",
    "MININT\SMSOSD\OSDLOGS",
    "Windows\System32\sysprep\Panther",
    "Windows\Panther",
    "_SMSTaskSequence",
    "SMSTSLog")

#Initiate folder copy routine
try
{
    fSearchAndCopy($aDirectories)
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
    [Microsoft.VisualBasic.Interaction]::MsgBox("Copy of content is complete.  Shutting down unit.",'OKOnly,Information', "Error encountered") | Out-Null
}
catch
{
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
    [Microsoft.VisualBasic.Interaction]::MsgBox("Error occured during the copy of the deployment files.",'OKOnly,Exclamation', "Error encountered") | Out-Null
    fReRunPrompt
    Exit
}
Start-Process "x:\windows\system32\wpeutil.exe" @('"shutdown"')


}

# Call fMain
fMain