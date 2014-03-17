<#
Purpose: Replaces Windows 8/8.1 Start Screen Background image.
Version: 1.0 - March 14, 2013

Author - Brian Gonzalez
    Blog   : http://supportishere.com

ChangeLog:
    2014-03-17 BFG:
        - Updated LogHelper output strings to match MDT logging strings.
        - set LogHelper to also write to BDD.log.
#>

# Create Global Variables
$oInvocation = (Get-Variable MyInvocation).Value
$sScriptDirectory = Split-Path $oInvocation.MyCommand.Path
$sScriptNameExt = $oInvocation.MyCommand.Name
$sScriptName = $sScriptNameExt.Substring(0, $sScriptNameExt.Length - 4)

# Ensure script can attach to TS Environment
try
{
    $ErrorActionPreference = "Stop"
    $oTSEnv = New-Object -COMObject Microsoft.SMS.TSEnvironment 
    $sLogPath = $oTSEnv.Value("LogPath")
    
}
catch [System.Runtime.InteropServices.COMException]
{
    $sLogPath = "C:\Windows\Temp\DeploymentLogs" #Hardcode Logs Directory    
}
finally
{$ErrorActionPreference = "Continue"}


# Set Logging File Variables
$sLogFilePath = "$sLogPath\$sScriptName.log"
$sCmdLogFilePath = "$sLogPath\$sScriptName-Cmd.log"
$sBDDLogFilePath = "$sLogPath\BDD.log"
$sTZbias = (Get-WmiObject -Query “Select Bias from Win32_TimeZone”).Bias
$sTime = ((Get-Date -Format hh:mm:ss.fff) + $sTZbias) 
$sDate = Get-Date -Format MM-dd-yyyy

# Function to run processes and capture output
function RunWithLogging
{
    param([string]$cmd,
    [string]$params)
    $ps = new-object System.Diagnostics.Process
    $ps.StartInfo.Filename = $cmd
    $ps.StartInfo.Arguments = $params
    $ps.StartInfo.RedirectStandardOutput = $True
    $ps.StartInfo.UseShellExecute = $false
    $ps.start() | Out-Null
    $ps.WaitForExit()
    [string] $out = $ps.StandardOutput.ReadToEnd();
    $out | Out-File $sCmdLogFilePath -Append
    return $ps.ExitCode
}

function CopyFileWithLogging
{
    param([string]$sSrcFile,
       [string]$sDesFile)
    If (!(Test-Path $sSrcFile))
    {LogHelper "$sSrcFile not found." "Error"}
    
    try
    {
        $ErrorActionPreference = "stop"
        Copy-Item $sSrcFile $sDesFile -Force
    }
    catch [System.Management.Automation.ItemNotFoundException]
    {
        LogHelper ("Could not find target location:  " + $sDesFile) "Error"
        return 1
    }
    catch [System.UnauthorizedAccessException]
    {
        LogHelper ("Access Error: Could not overwrite target file:  " + $sDesFile) "Error"
        return 2
    }
    finally {$ErrorActionPreference = "continue"}

    If (Test-Path $sDesFile)
    {
        LogHelper ($sDesFile + " was overwritten successfully.")
        return 0
    }
}


function LogHelper
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
                $sDate + """ component=""" + $sScriptName + """ context="""" type=""1"" thread="""" file=""" + `
                $sScriptName + """>")
        }
    }
    catch [System.IO.DirectoryNotFoundException]
    {
        Write-Host (Split-Path $sLogFilePath),"folder does not exist"
        New-Item -ItemType Directory (Split-Path $sLogFilePath) | Out-Null
        $sUpdateStringTest = ("<![LOG[Created Logging Directory.]LOG]!><time=""" + $sTime + """ date=""" + `
            $sDate + """ component=""" + $sScriptName + """ context="""" type=""1"" thread="""" file=""" + `
            $sScriptName + """>")
        $sUpdateStringTest | Out-File $sLogFilePath -Append -NoClobber -Encoding Default
    }
    finally {$ErrorActionPreference = "continue"}

    If ($sLogType -eq "Update")
    {
        # Write to log named after script file.
        $sUpdateStringTest = ("<![LOG[" + $sLogContent + "]LOG]!><time=""" + $sTime + """ date=""" + `
            $sDate + """ component=""" + $sScriptName + """ context="""" type=""1"" thread="""" file=""" + `
            $sScriptName + """>")
        $sUpdateStringTest | Out-File $sLogFilePath -Append -NoClobber -Encoding Default
        # Write also to BDD.log
        If (Test-Path $sBDDLogFilePath)
        {$sUpdateStringTest | Out-File $sBDDLogFilePath -Append -NoClobber -Encoding Default}
    }
    ElseIf (($sLogType -eq "Error") -or ($sLogType -eq "Failure"))
    {
        # Write to log named after script file.
        <![LOG[FAILURE (Err):
        $sUpdateStringTest = ("<![LOG[FAILURE (Err):" + $sLogContent + "]LOG]!><time=""" + $sTime + """ date=""" + `
            $sDate + """ component=""" + $sScriptName + """ context="""" type=""1"" thread="""" file=""" + `
            $sScriptName + """>")
        $sUpdateStringTest | Out-File $sLogFilePath -Append -NoClobber -Encoding Default
        # Write also to BDD.log
        If (Test-Path $sBDDLogFilePath)
        {$sUpdateStringTest | Out-File $sBDDLogFilePath -Append -NoClobber -Encoding Default}
    }
}


# Start Main Code Here

# Examples
# Run a Command Line
#LogHelper "About to run a command."
#$sCmd = "$env:SystemDrive\Windows\System32\cmd.exe"
#$sParams = "/C IPCONFIG /ALL"
#$sReturn = RunWithLogging $sCmd $sParams
#LogHelper "Command Completed and Returned: $sReturn"

# Copy a File/Folder
#$sSourceFilePath = ($sScriptDirectory + "\SourceFile.txt")
#$sDestinationFilePath = "C:\Temp"
#LogHelper ("About to copy """ + $sSourceFilePath + """ to " + $sDestinationFilePath)
#$sReturn = CopyFileWithLogging $sSourceFilePath $sDestinationFilePath
#LogHelper ("Copy is complete and returned: $sReturn")