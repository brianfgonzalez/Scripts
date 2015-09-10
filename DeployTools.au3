#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=DeployTools_x86.Exe
#AutoIt3Wrapper_Outfile_x64=DeployTools_x64.Exe
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Fileversion=1.1
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
FileInstall("cmtrace_x64.exe", @WindowsDir & "\system32\cmtrace_x64.exe", 1)
FileInstall("cmtrace_x86.exe", @WindowsDir & "\system32\cmtrace_x86.exe", 1)
FileInstall("cleandisk.bat", @WindowsDir & "\Temp\cleandisk.bat", 1)
FileInstall("RevertOS.ps1", @WindowsDir & "\Temp\RevertOS.ps1", 1)
FileInstall("OpenBDD.ps1", @WindowsDir & "\Temp\OpenBDD.ps1", 1)
FileInstall("OpenHelp.ps1", @WindowsDir & "\Temp\OpenHelp.ps1", 1)
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <Array.au3>
RunWait("CMD /C powershell -Command ""Set-ExecutionPolicy RemoteSigned -Confirm:$false""", @ScriptDir, @SW_HIDE)
Main()

Func Main()
    Local $msg
    $ComboMain = GUICreate("", 320, 100, 0, 0, $WS_POPUP + $WS_BORDER) ; will create a dialog box that when displayed is centered
	$ComboBox = GUICtrlCreateCombo("Open BDD Log", 10, 10, 300, 30, $CBS_DROPDOWNLIST) ; create first item
	GUICtrlSetFont($ComboMain,-1,700,-1,"Tahoma")
    GUICtrlSetData(-1, "Wipe Disk|Revert OS Images|Cancel Deployment|Reboot|Shutdown", "Open BDD Log") ; add other item snd set a new default
    $GoButton = GUICtrlCreateButton("Go", 110, 60, 100, 30)
	GUISetState()
	GUICtrlSetFont($ComboBox, 20, 10)
	GUICtrlSetFont($GoButton, 20, 10)

    ; Run the GUI until the dialog is closed
    While 1
        $msg = GUIGetMsg()
		Select
            Case $msg = $GUI_EVENT_CLOSE
                ExitLoop
            Case $msg = $GoButton
				GUICtrlSetState($GoButton, $GUI_DISABLE)
				$menutext = GUICtrlRead($ComboBox, 1) ; return the text of the menu item
				Select
					Case $menutext = "Open BDD Log"
						RunWait("CMD /C powershell -File " & @WindowsDir & "\temp\OpenBDD.ps1", @ScriptDir, @SW_HIDE)
					Case $menutext = "Wipe Disk"
						RunWait("CMD /C " & @WindowsDir & "\temp\cleandisk.bat", @ScriptDir, @SW_MAXIMIZE)
					Case $menutext = "Revert OS Images"
						RunWait("CMD /C powershell -File " & @WindowsDir & "\temp\RevertOS.ps1", @ScriptDir, @SW_MAXIMIZE)
					Case $menutext = "Help File"
						RunWait("CMD /C powershell -File " & @WindowsDir & "\temp\OpenHelp.ps1", @ScriptDir, @SW_HIDE)
					Case $menutext = "Cancel Deployment"
						ProcessClose("TsManager.exe")
						ProcessClose("TsProgressUI.exe")
					Case $menutext = "Reboot"
						RunWait("CMD /C " & @WindowsDir & "\system32\wpeutil.exe reboot", @ScriptDir, @SW_HIDE)
					Case $menutext = "Shutdown"
						RunWait("CMD /C " & @WindowsDir & "\system32\wpeutil.exe shutdown", @ScriptDir, @SW_HIDE)
				EndSelect
				GUICtrlSetState($GoButton, $GUI_ENABLE)
        EndSelect
    WEnd
EndFunc