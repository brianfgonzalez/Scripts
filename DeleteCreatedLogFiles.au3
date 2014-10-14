

MsgBox(0,"",@TempDir)
Exit
#include <Date.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <Array.au3>
Local $StartTimer = TimerInit()
Sleep(5000)
;MsgBox(0, "", $start)

; Populate array with all zip files inside of "src" sub-folder
$sSrcPath = "E:\Local Cloud\Shared\One-Click Bundles\Tools"
$sFilesOnly = 1
If FileExists($sSrcPath) Then
	$aDriverZips = _FileListToArray($sSrcPath, "*.zip", $sFilesOnly)
	_ArraySort($aDriverZips, 0, 1)
	_ArrayDisplay($aDriverZips)
EndIf


Local $AmountOfSecondsRun = TimerDiff($StartTimer/1000)
For $i = 1 To $aDriverZips[0]
	$sDriverZipPath = $sSrcPath & "\" & $aDriverZips[$i]
	$t = FileGetTime($sDriverZipPath, $FT_CREATED, 0)
	;_ArrayDisplay($t)
	Local $Date = $t[0] & '/' & $t[1] & '/' & $t[2] & ' ' & $t[3] & ':' & $t[4] & ':' & $t[5]
	MsgBox(0,"",_DateDiff('s', $Date, _NowCalc()) <= $AmountOfSecondsRun)
Next