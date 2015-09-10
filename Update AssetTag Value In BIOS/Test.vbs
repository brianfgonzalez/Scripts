Dim oNetwork, oFSO
Set oFSO = CreateObject("Scripting.FileSystemObject")
Set oFile = oFSO.CreateTextFile("C:\DesiredAssetTag.txt")
Set oNetwork = WScript.CreateObject("WScript.Network")
oFile.Write oNetwork.ComputerName