#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <Math.au3>

Global $_Gui, $_Guititle='AnimatedSplashs'
Global $_Image1, $_Width, $_Height, $_Ratio, $_LastWidth, $_LastHeight

HotKeySet ( "{ESC}", "_Exit" )
OnAutoItExitRegister ( '_Exit' )
AdlibRegister ( '_ReduceMemory', 5000 )

_DownloadPng ( )

ToolTip ( '         Example N°01/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\AWorldofKefling2.png" )
_SplashGoes ( @TempDir & "\Png\AWorldofKefling2.png" )

ToolTip ( '         Example N°02/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\Sonic1.png", 1 )
 Sleep ( 1000 )
_SplashGoes ( @TempDir & "\Png\Sonic1.png" )

ToolTip ( '         Example N°03/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashMove ( @TempDir & "\Png\Garfield1.png", ( @DesktopWidth-300 )/2, 0, ( @DesktopWidth-300 )/2, @DesktopHeight-225, 5 )
_SplashFade ( @TempDir & "\Png\Garfield1.png" )

ToolTip ( '         Example N°04/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\Pokemon1.png", 3 )
_SplashFade ( @TempDir & "\Png\Pokemon1.png" )

ToolTip ( '         Example N°05/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\TutanchamunMask2.png" )
_SplashGoes ( @TempDir & "\Png\TutanchamunMask2.png" )

ToolTip ( '         Example N°06/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\Skype1.png", 3 )
_SplashFade ( @TempDir & "\Png\Skype1.png" )

ToolTip ( '         Example N°07/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\Ubuntu1.png" )
_SplashGoes ( @TempDir & "\Png\Ubuntu1.png" )

ToolTip ( '         Example N°08/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashMove ( @TempDir & "\Png\Iphone1.png", 0, 0, @DesktopWidth-300, @DesktopHeight-237, 5 )
_SplashFade ( @TempDir & "\Png\Iphone1.png" )

ToolTip ( '         Example N°09/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashUnFade ( @TempDir & "\Png\DonkeyKong1.png" )
_SplashFade ( @TempDir & "\Png\DonkeyKong1.png" )

ToolTip ( '         Example N°10/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\ChanelNo5_1.png", 1.5 )
_SplashFade ( @TempDir & "\Png\ChanelNo5_1.png" )

ToolTip ( '         Example N°11/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\PirateBay1.png" )
_SplashFade ( @TempDir & "\Png\PirateBay1.png" )

ToolTip ( '         Example N°12/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashMove ( @TempDir & "\Png\Mario2.png", @DesktopWidth-200, @DesktopHeight-250, -50, -80, 5 )
_SplashFade ( @TempDir & "\Png\Mario2.png" )

ToolTip ( '         Example N°13/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\Safari1.png" )
_SplashGoes ( @TempDir & "\Png\Safari1.png" )

ToolTip ( '         Example N°14/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\Ring1.png", 1.5 )
_SplashFade ( @TempDir & "\Png\Ring1.png" )

ToolTip ( '         Example N°15/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\Lexus1.png" )
_SplashGoes ( @TempDir & "\Png\Lexus1.png" )

ToolTip ( '         Example N°16/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashMove ( @TempDir & "\Png\Mario&Yoshi1.png", -300, @DesktopHeight-200, @DesktopWidth-280, -30, 5 )
_SplashFade ( @TempDir & "\Png\Mario&Yoshi1.png" )

ToolTip ( '         Example N°17/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\Firefox1.png" )
_SplashFade ( @TempDir & "\Png\Firefox1.png" )

ToolTip ( '         Example N°18/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashMove ( @TempDir & "\Png\Shaun2.png", @DesktopWidth-199, -100, 0, @DesktopHeight-300, 5 )
_SplashMove ( @TempDir & "\Png\Shaun2.png", 0, @DesktopHeight-300, @DesktopWidth-199, @DesktopHeight-300, 5 )
_SplashMove ( @TempDir & "\Png\Shaun2.png", @DesktopWidth-199, @DesktopHeight-300, @DesktopWidth-199, (@DesktopHeight-400)/2, 5 )
_SplashMove ( @TempDir & "\Png\Shaun2.png", @DesktopWidth-199, (@DesktopHeight-400)/2, (@DesktopWidth-300)/2, (@DesktopHeight-300)/2, 5 )
_SplashFade ( @TempDir & "\Png\Shaun2.png" )

ToolTip ( '         Example N°19/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\GranTurismo1.png", 2 )
_SplashFade ( @TempDir & "\Png\GranTurismo1.png" )

ToolTip ( '         Example N°20/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\Diddy1.png" )
_SplashGoes ( @TempDir & "\Png\Diddy1.png" )

ToolTip ( '         Example N°21/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\TheGimp1.png" )
_SplashFade ( @TempDir & "\Png\TheGimp1.png" )

ToolTip ( '         Example N°22/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\Raiponce1.png" )
_SplashGoes ( @TempDir & "\Png\Raiponce1.png" )

ToolTip ( '         Example N°23/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashEnlarge ( @TempDir & "\Png\Tux1.png" )
_SplashFade ( @TempDir & "\Png\Tux1.png" )

ToolTip ( '         Example N°24/24' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
_SplashCome ( @TempDir & "\Png\Stars4.png" )
_SplashFade ( @TempDir & "\Png\Stars4.png" )

;_SplashMove ( @TempDir & "\Png\Garfield1.png", -60, ( @DesktopHeight-300 )/2, @DesktopWidth-250, ( @DesktopHeight-300 )/2, 3 )
;_SplashFade ( @TempDir & "\Png\Garfield1.png" )

Exit

Func _SplashMove ( $_PngPath, $_XStart=0, $_YStart=0, $_XEnd=0, $_YEnd=0, $_Step=5 )
	Local $_W=0
	$_XStart=Number ( $_XStart )
	$_YStart=Number ( $_YStart )
	$_XEnd=Number ( $_XEnd )
	$_YEnd=Number ( $_YEnd )
    If Not $_Image1 Then _ImageInit ( '', $_PngPath )
    If Not $_Gui Then $_Gui = GUICreate ( $_Guititle, $_Width , $_Height, -1, -1, -1, BitOR ( $WS_EX_LAYERED, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW ) )
    _SetBitMap ( $_Gui, $_Image1, 255, $_Width, $_Height )
    $_Z = ( _Max ( $_XStart, $_XEnd ) - _Min ( $_XStart, $_XEnd ) )/$_Step
	If $_Z Then
		$_Y = $_YStart
	    $_W = Abs ( ( _Max ( $_YStart, $_YEnd ) - _Min ( $_YStart, $_YEnd ) )/$_Z )
	    If $_XEnd < $_XStart Then $_Step = - Abs ( $_Step )
	    If $_YEnd < $_YStart Then $_W = -$_W
        For $_X = $_XStart To $_XEnd Step $_Step
		    WinMove ( $_Gui, "", $_X, $_Y )
	        GUISetState ( @SW_SHOW )
            $_Y = $_Y + $_W
            Sleep ( 10 )
        Next
    Else
		$_X = $_XStart
		If $_YEnd < $_YStart Then $_Step = - Abs ( $_Step )
        For $_Y = $_YStart To $_YEnd Step $_Step
		    WinMove ( $_Gui, "", $_X, $_Y )
	        GUISetState ( @SW_SHOW )
            Sleep ( 10 )
        Next
	EndIf
	_WinGetPos ( )
	Sleep ( 1000 )
EndFunc ;==> _SplashMove ( )

Func _SplashCome ( $_PngPath )
    If Not $_Image1 Then _ImageInit ( '', $_PngPath )
    If Not $_Gui Then $_Gui = GUICreate ( $_Guititle, $_Width , $_Height, -1, -1, -1, BitOR ( $WS_EX_LAYERED, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW ) )
    For $_Width = 50 To @DesktopWidth/4 Step 3
        WinMove ( $_Gui, "", ( @DesktopWidth - $_Width )/2, ( @DesktopHeight - $_Height )/2, $_Width, $_Width/$_Ratio )
		GUISetState ( @SW_SHOW )
        $_Image1 = _ImageResize ( $_PngPath, $_Width, $_Width/$_Ratio )
        _SetBitMap ( $_Gui, $_Image1, 255, $_Width, $_Width/$_Ratio )
        Sleep ( 10 )
    Next
	_WinGetPos ( )
	Sleep ( 1000 )
EndFunc ;==> _SplashCome ( )

Func _SplashGoes ( $_PngPath )
    For $_Width = $_LastWidth To 10 Step -12
        WinMove ( $_Gui, "", ( @DesktopWidth - $_Width )/2, ( @DesktopHeight - $_Height )/2 , $_Width, $_Width/$_Ratio )
		GUISetState ( @SW_SHOW )
        $_Image1 = _ImageResize ( $_PngPath, $_Width, $_Width/$_Ratio )
        _SetBitMap ( $_Gui, $_Image1, 255, $_Width, $_Width/$_Ratio )
        Sleep ( 10 )
    Next
    _ImageDispose ( $_Image1 )
    Sleep ( 1000 )
EndFunc ;==> _SplashGoes ( )

Func _SplashEnlarge ( $_PngPath, $_Coeff=1 )
    If Not $_Image1 Then _ImageInit ( '', $_PngPath )
    If Not $_Gui Then $_Gui = GUICreate ( $_Guititle, $_Width , $_Height, -1, -1, -1, BitOR ( $WS_EX_LAYERED, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW ) )
    For $_Width = 20 To $_Height*$_Coeff Step 5
	    WinMove ( $_Gui, "", ( @DesktopWidth - $_Width )/2, ( @DesktopHeight - $_Height )/2, $_Width, $_Height )
		GUISetState ( @SW_SHOW )
        $_Image1 = _ImageResize ( $_PngPath, $_Width, $_Height )
		_SetBitMap ( $_Gui, $_Image1, 255, $_Width, $_Height )
        Sleep ( 20 )
	Next
	_WinGetPos ( )
	Sleep ( 1000 )
EndFunc ;==> _SplashEnlarge ( )

Func _SplashFade ( $_PngPath )
	For $_I = 255 To 5 Step -5
		_SetBitMap ( $_Gui, $_Image1, $_I, $_LastWidth, $_LastHeight )
        Sleep ( 30 )
	Next
	_ImageDispose ( $_Image1 )
	Sleep ( 1000 )
EndFunc ;==> _SplashFade ( )

Func _SplashUnFade ( $_PngPath )
    If Not $_Image1 Then _ImageInit ( '', $_PngPath )
    If Not $_Gui Then $_Gui = GUICreate ( $_Guititle, $_Width, $_Height, -1, -1, -1, BitOR ( $WS_EX_LAYERED, $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW ) )
	WinMove ( $_Gui, "", ( @DesktopWidth - $_Width )/2, ( @DesktopHeight - $_Height )/2, $_Width, $_Height )
	_WinGetPos ( )
	For $_I = 5 To 255 Step 5
		_SetBitMap ( $_Gui, $_Image1, $_I, $_LastWidth, $_LastHeight )
		GUISetState ( @SW_SHOW )
        Sleep ( 80 )
	Next
	Sleep ( 1000 )
EndFunc ;==> _SplashUnFade ( )

Func _SetBitmap ( $hGUI, $hImage, $iOpacity, $n_width, $n_height )
    Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
    $hScrDC = _WinAPI_GetDC ( 0 )
    $hMemDC = _WinAPI_CreateCompatibleDC ( $hScrDC )
    $hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap ( $hImage )
    $hOld = _WinAPI_SelectObject ( $hMemDC, $hBitmap )
    $tSize = DllStructCreate ( $tagSIZE )
    $pSize = DllStructGetPtr ( $tSize )
    DllStructSetData ( $tSize, "X", $n_width )
    DllStructSetData ( $tSize, "Y", $n_height )
    $tSource = DllStructCreate ( $tagPOINT )
    $pSource = DllStructGetPtr ( $tSource )
    $tBlend = DllStructCreate ( $tagBLENDFUNCTION )
    $pBlend = DllStructGetPtr ( $tBlend )
    DllStructSetData ( $tBlend, "Alpha", $iOpacity )
    DllStructSetData ( $tBlend, "Format", 1 )
    _WinAPI_UpdateLayeredWindow ( $hGUI, $hScrDC, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA )
    _WinAPI_ReleaseDC ( 0, $hScrDC )
    _WinAPI_SelectObject ( $hMemDC, $hOld )
    _WinAPI_DeleteObject ( $hBitmap )
    _WinAPI_DeleteDC ( $hMemDC )
EndFunc ;==> _SetBitmap ( )

Func _ImageResize ( $sInImage, $newW, $newH, $sOutImage="" )
    Local $oldImage, $GC, $newBmp, $newGC
    If $sOutImage = "" Then _GDIPlus_Startup ( )
    $oldImage = _GDIPlus_ImageLoadFromFile ( $sInImage )
    $GC = _GDIPlus_ImageGetGraphicsContext ( $oldImage )
    $newBmp = _GDIPlus_BitmapCreateFromGraphics ( $newW, $newH, $GC )
    $newGC = _GDIPlus_ImageGetGraphicsContext ( $newBmp )
    _GDIPlus_GraphicsDrawImageRect ( $newGC, $oldImage, 0, 0, $newW, $newH )
    _GDIPlus_GraphicsDispose ( $GC )
    _GDIPlus_GraphicsDispose ( $newGC )
    _GDIPlus_ImageDispose ( $oldImage )
    If $sOutImage = "" Then
        Return $newBmp
    Else
        _GDIPlus_ImageSaveToFile ( $newBmp, $sOutImage )
        _GDIPlus_BitmapDispose ( $newBmp )
        _GDIPlus_Shutdown ( )
        Return 1
    EndIf
EndFunc ;==> _ImageResize ( )

Func _ImageInit ( $_PngUrl2, $_PngPath2 )
    _GDIPlus_Startup ( )
    $_Image1 = _GDIPlus_ImageLoadFromFile ( $_PngPath2 )
    $_Width = _GDIPlus_ImageGetWidth ( $_Image1 )
    $_Height = _GDIPlus_ImageGetHeight ( $_Image1 )
    $_Ratio = Round ( $_Width / $_Height )
EndFunc ;==> _ImageInit ( )

Func _ImageDispose ( $_Image )
	GUIDelete ( WinGetHandle ( $_Guititle, '' ) )
    _GDIPlus_GraphicsDispose ( $_Image )
    _GDIPlus_Shutdown ( )
	$_Image1=0
	$_Gui=0
EndFunc ;==> _ImageDispose ( )

Func _WinGetPos ( )
	$_Pos = WinGetPos ( $_Gui )
    $_LastWidth = $_Pos[2]
    $_LastHeight = $_Pos[3]
EndFunc ;==> _WinGetPos ( )

Func _DownloadPng ( )
    If Not FileExists ( @TempDir & '\Png' ) Then
		ToolTip ( 'Please Wait while Downloading png files' & @Crlf, @DesktopWidth/2-152, 0, $_Guititle, 1, 4 )
	    DirCreate ( @TempDir & '\Png' )
		InetGet ( 'http://img703.imageshack.us/img703/5733/aworldofkefling2.png', @TempDir & '\Png\AWorldofKefling2.png', 1, 1 )
		InetGet ( 'http://img529.imageshack.us/img529/6853/sonic1.png', @TempDir & '\Png\Sonic1.png', 1, 1 )
		InetGet ( 'http://img529.imageshack.us/img529/5671/garfield1.png', @TempDir & '\Png\Garfield1.png', 1, 1 )
		InetGet ( 'http://img411.imageshack.us/img411/4258/pokemon1g.png', @TempDir & '\Png\Pokemon1.png', 1, 1 )
		InetGet ( 'http://img146.imageshack.us/img146/9869/tutanchamunmask2.png', @TempDir & '\Png\TutanchamunMask2.png', 1, 1 )
		InetGet ( 'http://img403.imageshack.us/img403/210/skype1h.png', @TempDir & '\Png\Skype1.png', 1, 1 )
		InetGet ( 'http://img403.imageshack.us/img403/9844/ubuntu1.png', @TempDir & '\Png\Ubuntu1.png', 1, 1 )
		InetGet ( 'http://img408.imageshack.us/img408/8991/iphone1.png', @TempDir & '\Png\Iphone1.png', 1, 1 )
		InetGet ( 'http://img408.imageshack.us/img408/2994/donkeykong1.png', @TempDir & '\Png\DonkeyKong1.png', 1, 1 )
		InetGet ( 'http://img821.imageshack.us/img821/5380/chanelno51.png', @TempDir & '\Png\ChanelNo5_1.png', 1, 1 )
		InetGet ( 'http://img821.imageshack.us/img821/1236/piratebay1.png', @TempDir & '\Png\PirateBay1.png', 1, 0 )
		InetGet ( 'http://img443.imageshack.us/img443/1404/mario2ab.png', @TempDir & '\Png\Mario2.png', 1, 1 )
		InetGet ( 'http://img443.imageshack.us/img443/8411/safari1.png', @TempDir & '\Png\Safari1.png', 1, 1 )
		InetGet ( 'http://img508.imageshack.us/img508/1684/ring1x.png', @TempDir & '\Png\Ring1.png', 1, 1 )
		InetGet ( 'http://img249.imageshack.us/img249/5538/lexus1.png', @TempDir & '\Png\Lexus1.png', 1, 1 )
		InetGet ( 'http://img593.imageshack.us/img593/6880/marioyoshi1.png', @TempDir & '\Png\Mario&Yoshi1.png', 1, 1 )
		InetGet ( 'http://img593.imageshack.us/img593/7070/firefox1z.png', @TempDir & '\Png\Firefox1.png', 1, 1 )
		InetGet ( 'http://img337.imageshack.us/img337/5444/shaun2.png', @TempDir & '\Png\Shaun2.png', 1, 1 )
		InetGet ( 'http://img337.imageshack.us/img337/3172/granturismo1.png', @TempDir & '\Png\GranTurismo1.png', 1, 1 )
		InetGet ( 'http://img405.imageshack.us/img405/7430/diddy1.png', @TempDir & '\Png\Diddy1.png', 1, 1 )
		InetGet ( 'http://img823.imageshack.us/img823/172/thegimp1.png', @TempDir & '\Png\TheGimp1.png', 1, 1 )
		InetGet ( 'http://img823.imageshack.us/img823/1160/raiponce1.png', @TempDir & '\Png\Raiponce1.png', 1, 1 )
		InetGet ( 'http://img707.imageshack.us/img707/7681/tux1x.png', @TempDir & '\Png\Tux1.png', 1, 1 )
		InetGet ( 'http://img707.imageshack.us/img707/1083/stars4.png', @TempDir & '\Png\Stars4.png', 1, 0 )
    EndIf
	ToolTip ( '' )
EndFunc ;==> _DownloadPng ( )

Func _ReduceMemory ( )
	Local $_Handle = DllCall ( "kernel32.dll", "int", "OpenProcess", "int", 2035711, "int", False, "int", @AutoItPID )
    If Not @error Then Return DllCall ( "psapi.dll", "int", "EmptyWorkingSet", "long", $_Handle[0] )
EndFunc ;==> _ReduceMemory ( )

Func _Exit ( )
	ToolTip ( '' )
	_ImageDispose ( $_Image1 )
	Exit
EndFunc ;==> _Exit