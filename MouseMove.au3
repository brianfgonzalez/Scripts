#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=mouse.ico
#AutoIt3Wrapper_Outfile=MouseMove.exe
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
$x=0
Do
	MouseMove(0,0,10)
	MouseMove(800,800,10)
	MouseMove(800,0,10)
	MouseMove(0,800,10)
	Sleep(1000)
Until $x=1