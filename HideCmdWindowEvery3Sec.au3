#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=CmdPrompt.ico
#AutoIt3Wrapper_Outfile=HideCmdWindowEvery3Sec.exe
#AutoIt3Wrapper_Res_Comment=contact imaging@us.panasonic.com for support.
#AutoIt3Wrapper_Res_Description=Close Command Windows Every 3 Seconds.
#AutoIt3Wrapper_Res_Fileversion=1.0
#AutoIt3Wrapper_Res_LegalCopyright=Panasonic Corporation Of North America
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
Opt("WinTitleMatchMode", 2)

$i = 0
Do
   If NOT (WinGetState("[CLASS:ConsoleWindowClass]") = "16") Then ; If window is not Minimized
	  WinSetState(WinGetTitle("[CLASS:ConsoleWindowClass]"), "", @SW_MINIMIZE)
   EndIf
   Sleep(3000) ; 3 second delay
Until $i = 10 ; Enless Loop