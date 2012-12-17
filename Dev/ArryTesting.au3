#include <Array.au3>
Local $avArray[6] = ["99_Install1", "99_Install2", "99_Install3", "Install1", "Install2", "Install6"]
$sInput = _ArrayToString($avArray, ",")
$sTestQuery = '\Q99_\E.*?,'
$sOutput = StringRegExpReplace($sInput, $sTestQuery, "")
$sOutArray = StringSplit($sOutput, ",")