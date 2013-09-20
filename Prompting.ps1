[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
        [Microsoft.VisualBasic.Interaction]::MsgBox("Image was recovered. Click OK to Shut Down the System.",'OKOnly,Information', "Process Complete")

Exit

$sig = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
Add-Type -MemberDefinition $sig -name NativeMethods -namespace Win32
$hwnd = @(Get-Process "*cmd.exe*")[0].MainWindowHandle
[Win32.NativeMethods]::ShowWindowAsync($hwnd, 3)

Exit


[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
$a = Get-Process | Where-Object {$_.Name -eq "Notepad"}
$shell = New-Object -ComObject “Shell.Application”
$shell.MinimizeAll()
$shell.MinimizeAll()
Exit



Exit

C:\windows\system32\robocopy.exe "D:\BK Backup Test" "D:" /copyall /NJH /NJS /NP
Exit

Start-Process "C:\windows\system32\robocopy.exe" @(' "' + 'D:\BK Backup' + `
    '\*" ' + 'D:\BK Backup Test' + '\" /MIR /NJH /NJS /NP') -Wait -NoNewWindow
exit




[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") | Out-Null
$Answer = [Microsoft.VisualBasic.Interaction]::MsgBox("Do you agree?",'YesNoCancel,Question', "Respond please")
Write-Host "Answer was given... $Answer"
#[Microsoft.VisualBasic.Strings]::StrConv("surely you must be joking, mr. teddy",'ProperCase')
Exit



# Script name: YesNoPrompt.ps1
# Created on: 2007-01-07
# Author: Kent Finkle
# Purpose: How Can I Give a User a Yes/No Prompt in Powershell?
 
$a = new-object -comobject wscript.shell
$intAnswer = $a.popup("Do you want to delete these files?", `
0,"Delete Files",4)
If ($intAnswer -eq 6) {
  $a.popup("You answered yes.")
} else {
  $a.popup("You answered no.")
}
 
#Button Types 
#
#Value Description 
#0 Show OK button.
#1 Show OK and Cancel buttons.
#2 Show Abort, Retry, and Ignore buttons.
#3 Show Yes, No, and Cancel buttons.
#4 Show Yes and No buttons.
#5 Show Retry and Cancel buttons.