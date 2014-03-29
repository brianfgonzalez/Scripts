$ErrorActionPreference = "Stop"
<#
Purpose: ZTI/LTI Utility script written in Powershell (Swis-Army knife)
Included Functions: RunWithLogging, CopyWithLogging, and LogHelper
Version: 1.1 - March 29, 2014

Author - Brian Gonzalez
    Blog   : http://supportishere.com

ChangeLog:
    2014-03-17 BFG:
        - First Revision
    2014-03-29 BFG:
        - Consolidated variables to one dictionary for easy access
        - Bug fixed the RunWithLogging and LogHelper function
#>

<# Populate oPSUtility Properties
    .ScriptDirectory = Full Directory path for script, withOUT trailing "\".
    .ScriptNameWithExtension =  Filename of script with file extension.
    .ScriptName = Filename of script withOUT file extension (used when naming log file).
    .SystemDrive = System drive withOUT trailing "\".
#>

$oPSUtility = @{
        "ScriptDirectory" = (Split-Path $oInvocation.MyCommand.Path)
        "ScriptNameWithExtension" = $oInvocation.MyCommand.Name
        "SystemDrive" = $env:SystemDrive
    }
$oPSUtility.Add("ScriptName", $oPSUtility.ScriptNameWithExtension.Substring(0, $oPSUtility.ScriptNameWithExtension.Length - 4))

# Ensure script can attach to TS Environment
try
{
    $ErrorActionPreference = "Stop"
    $oTSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment
    $sLogPath = $oTSEnv.Value("LogPath")
    $oPSUtility.Add("LogPath", $sLogPath)    
}
catch #[System.Runtime.InteropServices.COMException]
# Hardcodes Logs Directory if unable to connect to TS object
{
    $sLogPath = "C:\Windows\Temp\DeploymentLogs"
    $oPSUtility.Add("LogPath", $sLogPath)
}
finally
{$ErrorActionPreference = "Continue"}

# Set Logging File Variables
$sLogFilePath = ($oPSUtility.LogPath + "\" + $oPSUtility.ScriptName + ".log")
$sCmdLogFilePath = ($oPSUtility.LogPath + "\" + $oPSUtility.ScriptName + "-Cmd.log")
$sBDDLogFilePath = ($oPSUtility.LogPath + "\BDD.log")
$sTZbias = (Get-WmiObject -Query “Select Bias from Win32_TimeZone”).Bias
$sTime = ((Get-Date -Format hh:mm:ss.fff) + $sTZbias) 
$sDate = Get-Date -Format MM-dd-yyyy

# Function to run processes and capture output
<#
    RunWithLogging: Runs a command with argument and logs an ExitCode and Console feedback.

    Arguments are pased in an order and NOT named.
    1 - Command Executable (must be a file that can be located).
    2 - Arguments for command line.
    3 - Boolean for logging console feedback.

    i.e.
    RunWithLogging "cmd.exe" "/C ipconfig /all"
    CopyWithLogging "setup.exe" "-s -f2c:\windows\temp\setup.log"
#>
function RunWithLogging
{
    param([string]$cmd,
    [string]$params,
	[boolean] $bLog = $true)

    # Verify the Command Exists.
    $sRelativePath = ($oPSUtility.ScriptDirectory + "\" + $cmd)
    $sSystem32Path = ($oPSUtility.SystemDrive + "\Windows\System32\" + $cmd)
    If (Test-Path $cmd) {}
    ElseIf (Test-Path $sSystem32Path) {$cmd = $sSystem32Path}
    ElseIf (Test-Path $sRelativePath) {$cmd = $sRelativePath}
    Else
    {
        LogHelper ($cmd + " command was not found.") "Error"
        return 1
    }
    LogHelper ("Command executable existance confirmed: " + $sCmd)
    $ps = new-object System.Diagnostics.Process
    $ps.StartInfo.Filename = $cmd
    $ps.StartInfo.Arguments = $params
    $ps.StartInfo.RedirectStandardOutput = $True
    $ps.StartInfo.UseShellExecute = $false
    $ps.StartInfo.CreateNoWindow = $true
    LogHelper ("Running Command: " + $cmd + " " + $params)
    If ($bLog) {"Running Command: " + $cmd + " " + $params | Out-File $sCmdLogFilePath -Append}
    $ps.start() | Out-Null
    #$ps.WaitForExit()
    [string] $out = $ps.StandardOutput.ReadToEnd();
    If ($bLog) {$out | Out-File $sCmdLogFilePath -Append}
    If ($bLog) {"Command Completed with Return: " + $ps.ExitCode | Out-File $sCmdLogFilePath -Append}
    LogHelper ("Command Completed with Return: " + $ps.ExitCode)
    return $ps.ExitCode
}

function CopyWithLogging
<#
    CopyWithLogging: Copies either a directory (and contents) or single file.

    Arguments are pased in an order and NOT named.
    1 - File/Folder source location.
    2 - File/Folder destination location.

    i.e.
    CopyWithLogging "$sScriptDirectory\Configuration.ini" "$sSysDrive\Windows\System32"
    CopyWithLogging "$sScriptDirectory\Source" "$sSysDrive\Windows\Temp\Source"
#>
{
    param([string]$sSrcLocation,
       [string]$sSDesLocation)
    #LogHelper ("TestPath for """ + $sSrcLocation + """ returns: " + (Test-Path -Path "$sSrcLocation"))
    If (!(Test-Path $sSrcLocation))
    {LogHelper "$sSrcLocation not found." "Error"}
    
    try
    {
        $ErrorActionPreference = "stop"
        # Check if Source is a Folder
        If (Test-Path $sSrcLocation -pathType container)
        {
        # If Folder path ends in *, remove it.
        If ($sSrcLocation.SubString($sSrcLocation.Length-1, 1) -eq "*")
        {$sSrcLocation = $sSrcLocation.SubString(0, $sSrcLocation.Length-1)}
        # If Folder path ends in \, remove it.
        If ($sSrcLocation.SubString($sSrcLocation.Length-1, 1) -eq "\")
        {$sSrcLocation = $sSrcLocation.SubString(0, $sSrcLocation.Length-1)}
        # If Folder, add a \* to ensure all of sub-content is captured
		$sSrcLocation = "$sSrcLocation\*"
        # Create a TXT file in destination folder to ensure folder exists before copy occurs
		New-Item -ItemType File -Path "$sSDesLocation\temp.txt" -Force | Out-Null
        # Copy the content WITH the recurse flag
		Copy-Item $sSrcLocation $sSDesLocation -Force -Recurse
	}
	Else # Just perform a straight copy with NO recurse.
	{Copy-Item $sSrcLocation $sSDesLocation -Force}

    # Delete the temp.txt file previously created.
	If (Test-Path "$sSDesLocation\temp.txt")
	{Remove-Item "$sSDesLocation\temp.txt" -Force}
    }
    catch [System.Management.Automation.ItemNotFoundException] # Catch an exception of Item not found.
    {
        LogHelper ("Could not find target location:  " + $sSDesLocation) "Error"
        return 1
    }
    catch [System.UnauthorizedAccessException] # Catch an exception for an access issue.
    {
        LogHelper ("Access Error: Could not copy to target location:  " + $sSDesLocation) "Error"
        return 2
    }
    finally {$ErrorActionPreference = "continue"}

    # Verify the Destination now exists and toss an entry in the log file.
    If (Test-Path $sSDesLocation)
    {
        LogHelper ("""$sSrcLocation"" was copied to ""$sSDesLocation"" successfully.")
        return 0
    }
}


function LogHelper
<#
    LogHelper: Write log content to both the <ScriptName>.log and the BDD.log in the appropiate MDT Directory.

    Arguments are pased in an order and NOT named.
    1 - Logging Content String
    2 - Log Type, defaults to "Update", but can be set to "Error"

    i.e.
    LogHelper "Installing 7-Zip is complete."
    LogHelper "7-Zip installation failed." "Error"
#>
{
    param([string] $sLogContent,
    [string] $sLogType = "Update")

    try
    {
        $ErrorActionPreference = "stop"
        If (!(Test-Path $sLogFilePath))
        {
            # Create Log File
            $sUpdateStringTest = ("<![LOG[Initial LOG Entry]LOG]!><time=""" + $sTime + """ date=""" + `
                $sDate + """ component=""" + $oPSUtility.ScriptName + """ context="""" type=""1"" thread="""" file=""" + `
                $oPSUtility.ScriptName + """>")
        }
    }
    catch [System.IO.DirectoryNotFoundException]
    {
        Write-Host (Split-Path $sLogFilePath),"folder does not exist"
        New-Item -ItemType Directory (Split-Path $sLogFilePath) | Out-Null
        $sUpdateStringTest = ("<![LOG[Created Logging Directory.]LOG]!><time=""" + $sTime + """ date=""" + `
            $sDate + """ component=""" + $oPSUtility.ScriptName + """ context="""" type=""1"" thread="""" file=""" + `
            $oPSUtility.ScriptName + """>")
        $sUpdateStringTest | Out-File $sLogFilePath -Append -NoClobber -Encoding Default
    }
    finally {$ErrorActionPreference = "continue"}

    If ($sLogType -eq "Update")
    {
        # Write to log named after script file.
        $sUpdateStringTest = ("<![LOG[" + $sLogContent + "]LOG]!><time=""" + $sTime + """ date=""" + `
            $sDate + """ component=""" + $oPSUtility.ScriptName + """ context="""" type=""1"" thread="""" file=""" + `
            $oPSUtility.ScriptName + """>")
        $sUpdateStringTest | Out-File $sLogFilePath -Append -NoClobber -Encoding Default
        # Write also to BDD.log
        If (Test-Path $sBDDLogFilePath)
        {$sUpdateStringTest | Out-File $sBDDLogFilePath -Append -NoClobber -Encoding Default}
    }
    ElseIf (($sLogType -eq "Error") -or ($sLogType -eq "Failure"))
    {
        # Write to log named after script file.
        $sUpdateStringTest = ('<![LOG[FAILURE (Err):' + $sLogContent + ']LOG]!><time="' + $sTime + '" date="' + `
            $sDate + '" component="' + $oPSUtility.ScriptName + '" context="" type="1" thread="" file="' + `
            $oPSUtility.ScriptName + '">')
        $sUpdateStringTest | Out-File $sLogFilePath -Append -NoClobber -Encoding Default
        # Write also to BDD.log
        If (Test-Path $sBDDLogFilePath)
        {$sUpdateStringTest | Out-File $sBDDLogFilePath -Append -NoClobber -Encoding Default}
    }
}