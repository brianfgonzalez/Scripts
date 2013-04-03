#include <File.au3>
#include <Array.au3>

; Grab Sub-Folder path containing driver zip files
$foldersOnly = 2
$aSubFolders = _FileListToArray(@ScriptDir, "*", 2)
If @error = 1 Then
    MsgBox(0, "", "No Folders Found.")
    Exit
EndIf
If @error = 4 Then
    MsgBox(0, "", "No Files/Folders Found.")
    Exit
EndIf
$sSubFolder = @ScriptDir & "\" & $aSubFolders[1]



Exit