;FileInstall("joindomain.exe", @WindowsDir & "\Temp\joindomain.exe", 1)
;FileInstall("netdom.exe", @WindowsDir & "\system32\netdom.exe", 1)
;FileInstall("netdom.exe.mui", @WindowsDir & "\system32\en-US\netdom.exe.mui", 1)
;FileInstall("joindomain.exe", @WindowsDir & "\Temp\joindomain.exe", 1)
#include <GUIConstantsEx.au3>
#include <ComboConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
;$sWSNAMECmdPath = @WindowsDir & "\Temp\wsname.exe"

Example()

Func Example()
    Local $msg
    GUICreate("", 320, 100, 0, 0, $WS_POPUP) ; will create a dialog box that when displayed is centered
	$ComboBox = GUICtrlCreateCombo("Wipe Disk", 10, 10, 300, 30, $CBS_DROPDOWNLIST) ; create first item
    GUICtrlSetData(-1, "Revert OS Images|Cancel Deployment", "Wipe Disk") ; add other item snd set a new default
    $GoButton = GUICtrlCreateButton("Go", 110, 60, 100, 30)
	GUISetState()
	GUICtrlSetFont($ComboBox, 20, 10)
	GUICtrlSetFont($GoButton, 20, 10)
	Sleep(10000)
	Exit

    ; Run the GUI until the dialog is closed
    While 1
        $msg = GUIGetMsg()
		Select
            Case $msg = $GUI_EVENT_CLOSE
                ExitLoop
            Case $msg = $GoButton ;Change Computer Name.
				$menutext = GUICtrlRead($ComboBox, 1) ; return the text of the menu item
				Select
					Case $menutext = "Student Tablet"
						;Run($sWSNAMECmdPath & " /RESPACE /N:STUTAB$SERIALNUM[6+] /LOG C:\Windows\Temp\WSNAME.txt", @ScriptDir, @SW_HIDE)
					Case $menutext = "Student Cart"
						;Run($sWSNAMECmdPath & " /RESPACE /N:STUSCTAB$SERIALNUM[6+] /LOG C:\Windows\Temp\WSNAME.txt", @ScriptDir, @SW_HIDE)
					Case $menutext = "Special Education"
						;Run($sWSNAMECmdPath & " /RESPACE /N:STUSETAB$SERIALNUM[6+] /LOG C:\Windows\Temp\WSNAME.txt", @ScriptDir, @SW_HIDE)
					Case $menutext = "Alternate Education"
						;Run($sWSNAMECmdPath & " /RESPACE /N:STUAETAB$SERIALNUM[6+] /LOG C:\Windows\Temp\WSNAME.txt", @ScriptDir, @SW_HIDE)
				EndSelect
        EndSelect
    WEnd
EndFunc

;Run("cmd /c reg add ""HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Runonce"" /V runforme /d c:\windows\temp\joindomain.exe /f")
;Run("shutdown /r /t 05")