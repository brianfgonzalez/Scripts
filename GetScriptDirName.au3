#include <File.au3>
#include <Array.au3>

Local $szDrive, $szDir, $szFName, $szExt
Local $TestPath = _PathSplit(@ScriptFullPath, $szDrive, $szDir, $szFName, $szExt)
MsgBox(0, "", StringMid($TestPath[2], 2, StringLen($TestPath[2]) - 2))
