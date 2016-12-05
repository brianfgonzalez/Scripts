
'On Error Resume Next
Dim FSO, sSPFile, PercentageComplete, sProgressValue
Dim SPPercentage, LPPercentage, Drivepath, RootPath
Dim printersCaptured
Dim printersRestored
Dim networkSharesCaptured
Dim networkSharesRestored
Dim OldPCName
Dim scanStateExitCode
Dim loadStateExitCode

Dim USMTTaskname

Set FSO = CreateObject("Scripting.FileSystemObject")
Const ForReading = 1
USMTTaskname = "Run USMT"

FindPath()

On Error Resume Next

MBToTransfer(DrivePath & "\USMTcapture.prg")
SPPercentComplete(DrivePath & "\USMTcapture.prg")
LPPercentComplete(DrivePath & "\Loadstateprogress.log")
'LPPercentComplete(DrivePath & "\Loadstateprogress.prg")

printersCaptured = GetPrinetrsCount()
networkSharesCaptured = GetNetworkShareCount()

'printersRestored = GetPrinetrsCount(DrivePath & "\PrintersRestored.xml")
'networkSharesRestored = GetNetworkShareCount(DrivePath & "\PrintersRestored.xml")

GetOldPCComputerName(RootPath & "\OldPCName.txt")

GetRestoreProcessExitCode()



GetScanProcessExitCode(DrivePath & "\OSDSetupWizardOldPC.log")



WriteTSVariables()



'||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
'Functions & Subroutines
'||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
Function MBToTransfer(sSPFile)
Dim oFile, strContents, arrWords
Dim strWord, sTrim
Set oFile = FSO.OpenTextFile(sSPFile, ForReading)

strContents = oFile.ReadAll
oFile.Close

arrWords = Split(strContents, vbCr)
For Each strWord in arrWords
    If InStr(strWord, "totalSizeInMBToTransfer") Then
        'Wscript.echo strWord 
        sTrim = instrrev(strWord, "," )
            'Wscript.echo sTrim
        sProgressValue = Right(strWord,Len(strWord) -sTrim) 
            'Wscript.echo sProgressValue     
    End IF
Next
End Function 


Function SPPercentComplete(sFile)
Dim oFile, strContents, arrWords
Set oFile = FSO.OpenTextFile(sFile, ForReading)

strContents = oFile.ReadAll
oFile.Close

    arrWords = Split(strContents, vbCr)

        dim arrCount 'as int
        arrCount = Ubound(arrWords) -1

dim strSeq ' as string
strSeq = "totalPercentageCompleted"
dim i ' as int

' loop thru backwards to find sequence
for i = arrCount to 0 step -1
    
    dim pos ' as int
    pos = Instr( arrWords(i), strSeq ) 
    if pos > 0 then    

        ' ex: 15 Jan 2011, 20:46:21 -08:00, 00:04:48, totalPercentageCompleted, 48
        dim tmpResult ' as string
        tmpResult = Right ( arrWords(i), pos -1)
        PercentageComplete = Right (tmpResult, 3)
        SPPercentage = PercentageComplete
         'Wscript.echo SPPercentage
        exit for
    end if
Next    
End Function 

Function LPPercentComplete(sFile)
Dim oFile, strContents, arrWords
Set oFile = FSO.OpenTextFile(sFile, ForReading)

    ' check if file exists
    if FSO.FileExists(sFile) = False Then
        Set PathEnv = CreateObject("Microsoft.SMS.TSEnvironment")
        PathEnv("OSDLoadStateLogExists") = "False"        
        Exit Function    
    End If

strContents = oFile.ReadAll
oFile.Close

    arrWords = Split(strContents, vbCr)

        dim arrCount 'as int
        arrCount = Ubound(arrWords) -1

dim strSeq ' as string
strSeq = "totalPercentageCompleted"
dim i ' as int

' loop thru backwards to find sequence
for i = arrCount to 0 step -1
    
    dim pos ' as int
    pos = Instr( arrWords(i), strSeq ) 
    if pos > 0 then    

        ' ex: 15 Jan 2011, 20:46:21 -08:00, 00:04:48, totalPercentageCompleted, 48
        dim tmpResult ' as string
        tmpResult = Right ( arrWords(i), pos -1)
        PercentageComplete = Right (tmpResult, 3)
        LPPercentage = PercentageComplete
        'Wscript.echo LPPercentage
        exit for
    end if
Next    
End Function 

Function GetPrinetrsCount()

    Dim objXMLDoc, Root, NodeList
    Set objXMLDoc = CreateObject("Microsoft.XMLDOM") 
    objXMLDoc.async = False 
    Dim sFile 
	sFile = DrivePath & "\PrinterList.xml"
    ' check if file exists
    if FSO.FileExists(sFile) = False Then
        sFile = RootPath & "\PrinterList.xml"
	if FSO.FileExists(sFile) = False Then
	        Set PathEnv = CreateObject("Microsoft.SMS.TSEnvironment")
        	PathEnv("OSDGetPrintersLogExists") = "False"        
	        Exit Function   
	End If 
    End If

    If objXMLDoc.load(sFile) Then
        Set Root = objXMLDoc.documentElement 
        Set NodeList = Root.getElementsByTagName("Printer") 
       ' wscript.echo NodeList.length
        GetPrinetrsCount = NodeList.length
    Else
        wscript.echo "Failed to load"
    End If

    Set objXMLDoc = Nothing

End Function 



Function GetNetworkShareCount()

    Dim objXMLDoc, Root, NodeList
    Set objXMLDoc = CreateObject("Microsoft.XMLDOM") 
    objXMLDoc.async = False 
    Dim sFile 
	sFile = DrivePath & "\PrinterList.xml"
    ' check if file exists
    if FSO.FileExists(sFile) = False Then
        sFile = RootPath & "\PrinterList.xml"
	if FSO.FileExists(sFile) = False Then
	        Set PathEnv = CreateObject("Microsoft.SMS.TSEnvironment")
        	PathEnv("OSDGetPrintersLogExists") = "False"        
	        Exit Function   
	End If 
    End If

    If objXMLDoc.load(sFile) Then
        Set Root = objXMLDoc.documentElement 
        Set NodeList = Root.getElementsByTagName("NetworkShare") 
       ' wscript.echo NodeList.length
        GetNetworkShareCount = NodeList.length
    Else
        wscript.echo "Failed to load"
    End If

    Set objXMLDoc = Nothing
End Function 


Function GetOldPCComputerName(sFile)

    Dim oFile, strContents, arrWords
    
    Set oFile = FSO.OpenTextFile(sFile, ForReading)
    'strContents = oFile.ReadAll
    OldPCName = oFile.ReadLine
    oFile.Close
    
End Function

Function GetRestoreProcessExitCode()

    Dim smsFile
    Dim oFile, strContents, arrLines, eachLine
    Dim strWord, sTrim
    Dim oFolder

    Dim logFileName
    ''For each file that starts witj smsts*.log
    Dim foundExitCode
    
    foundExitCode = False
    set oFolder = FSO.GetFolder(DrivePath)

    For Each smsFile In oFolder.Files
        If (foundExitCode = False) Then ' Skip if exit code already found 
            If ( UCase (Left (smsFile.Name, 5)) = "SMSTS" ) Then  ' read only smsts files
               
                logFileName = DrivePath & "\" & smsFile.Name
                'smsFile = DrivePath & "\SMSTS.log"
                Set oFile = FSO.OpenTextFile(logFileName, ForReading)        
                strContents = oFile.ReadAll
                oFile.Close
                arrLines = Split(strContents, vbCr)
                For Each eachLine in arrLines
                    If (foundExitCode = False) Then
'  <![LOG[LoadState return code: 0]LOG]!><time="21:05:56.124+480" date="02-19-2011" component="InstallSoftware" context="" type="1" thread="2776" file="runcommandline.cpp:34">
                        If InStr(eachLine, "LoadState return code:") Then
                            foundExitCode = True
	                        sColon = instr(eachLine, ":" )
                            sTrim = instr(eachLine, "]" )
                            loadStateExitCode = Mid(eachLine,sColon+1 , sTrim-1-sColon ) 
                            '    Wscript.echo loadStateExitCode     
                        End If
                    End If
                Next

            End If
        End If 
	Next
    
    If (foundExitCode = False) Then
        loadStateExitCode = 0
    End If
    
End Function






Function GetScanProcessExitCode(smsFile)

    Dim oFile, strContents, arrLines, eachLine
    Dim strWord, sTrim
    Dim foundExitCode
    
    Set oFile = FSO.OpenTextFile(smsFile, ForReading,,true)  
    foundExitCode = False
    strContents = oFile.ReadAll
    oFile.Close

    Dim sANSIFileName
    Dim oANSIFile

    sANSIFileName = DrivePath & "\OSDRefreshWizardANSI.log"
    'OpenTextFile(destination, forwriting, createnew, open as Ascii) 
    Set oANSIFile = FSO.OpenTextFile(sANSIFileName, 2, True, False)
    oANSIFile.Write strContents
    oANSIFile.Close
    Set oANSIFile = Nothing

    Set oANSIFile = FSO.OpenTextFile(sANSIFileName, 1, , False)
    strContents = oANSIFile.ReadAll
    oANSIFile.Close
    Set oANSIFile = Nothing

    If FSO.FileExists(sANSIFileName) Then
       FSO.DeleteFile sANSIFileName 
      ' Wscript.echo "File deleted"
    End If 

    arrLines = Split(strContents, vbCr)
   
    For Each eachLine in arrLines
   
        If (InStr(eachLine, USMTTaskname) > 0) Then
            If (InStr(eachLine, "exit code =")) Then
                foundExitCode = True
                sTrim = instr(eachLine, "exit code =" )

' USMT log line from Wizard log: 
' 18:18:58.906 02-15-2011	1	TaskManager	Finished running task 'Run USMT'. Status = 'Error', exit code =26, task return code = 0
                scanStateExitCode = Trim( Mid (eachLine, sTrim+11, Instr(sTrim,eachLine,",")-(sTrim+11) ) )
                'Wscript.echo "Scan process Exit code :" & scanStateExitCode     
            End IF
        End IF
    Next

'    If (foundExitCode = False) Then
'        scanStateExitCode = 0
'    End If
    
End Function

Sub WriteTSVariables()
    dim Env
    dim UserStateLocal
    dim UserStateNetwork
    dim UserStateUSB
    dim osd: 
    set Env = CreateObject("Microsoft.SMS.TSEnvironment")

   ' Set a variable in the Operating System Deployment environment.
   
    Env("OSDDataMigrationToTransfer") = sProgressValue 
    Env("OSDDataMigrationScanned") = SPPercentage
    
    'If loadstateExitCode is '0' then set loadtstate percentage to 100 
    'as loadstate.exe is not logging 100% in its Loadprogress log eventhough it completed succesfully
    If (loadStateExitCode = 0 ) Then
        LPPercentage = "100"
    End IF
    Env("OSDDataMigrationRestored") = LPPercentage     

    Env("OSDNumberOfPrintersCaptured") = printersCaptured
    Env("OSDNumberOfNetworkSharesCaptured") = networkSharesCaptured
    '   Env("OSDNumberOfPrintersRestored") = printersRestored
    '   Env("OSDNumberOfNetworkSharesRestored") = networkSharesRestored
    
    Env("OSDOldComputerName") = OldPCName
    'OSDDataSourceDrive

   
    If ( Env("OSDHardLinks") = "TRUE") Then
        Env("OSDDataTransferType") = "Local"
    ElseIf  Env("SMSConnectNetworkFolderPath") <> "" Then
        Env("OSDDataTransferType") = "Network"
    ElseIf Env("OSDDataSourceDrive") <> "" Then
        Env ("OSDDataTransferType") = "USB"
    Else
       Env ("OSDDataTransferType") = "False"
    End If 

    Env("OSDCaptureProcessExitCode") = scanStateExitCode
    Env("OSDRestoreProcessExitCode") = loadStateExitCode

End Sub

Sub FindPath()
Dim PathEnv
  Set PathEnv = CreateObject("Microsoft.SMS.TSEnvironment")

 ' You can query the environment to get an existing USB path variable.
   'DrivePath = PathEnv("OSDStateStorePath") & "\" &  PathEnv("OSDDataSourceDirectory")
   'LogsPath = PathEnv("_SMSTSLogPath") 
   DrivePath = PathEnv("OSDStateStorePath") & "\SCCMLogs"
   RootPath = PathEnv("OSDStateStorePath") 
   'wscript.echo DrivePath 
End Sub


'' SIG '' Begin signature block
'' SIG '' MIIaWgYJKoZIhvcNAQcCoIIaSzCCGkcCAQExCzAJBgUr
'' SIG '' DgMCGgUAMGcGCisGAQQBgjcCAQSgWTBXMDIGCisGAQQB
'' SIG '' gjcCAR4wJAIBAQQQTvApFpkntU2P5azhDxfrqwIBAAIB
'' SIG '' AAIBAAIBAAIBADAhMAkGBSsOAwIaBQAEFFaxvnpuW8HZ
'' SIG '' 8tA6Jsv8VrUFbpHgoIIVNjCCBKkwggORoAMCAQICEzMA
'' SIG '' AACIWQ48UR/iamcAAQAAAIgwDQYJKoZIhvcNAQEFBQAw
'' SIG '' eTELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWlj
'' SIG '' cm9zb2Z0IENvZGUgU2lnbmluZyBQQ0EwHhcNMTIwNzI2
'' SIG '' MjA1MDQxWhcNMTMxMDI2MjA1MDQxWjCBgzELMAkGA1UE
'' SIG '' BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV
'' SIG '' BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBD
'' SIG '' b3Jwb3JhdGlvbjENMAsGA1UECxMETU9QUjEeMBwGA1UE
'' SIG '' AxMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMIIBIjANBgkq
'' SIG '' hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs3R00II8h6ea
'' SIG '' 1I6yBEKAlyUu5EHOk2M2XxPytHiYgMYofsyKE+89N4w7
'' SIG '' CaDYFMVcXtipHX8BwbOYG1B37P7qfEXPf+EhDsWEyp8P
'' SIG '' a7MJOLd0xFcevvBIqHla3w6bHJqovMhStQxpj4TOcVV7
'' SIG '' /wkgv0B3NyEwdFuV33fLoOXBchIGPfLIVWyvwftqFifI
'' SIG '' 9bNh49nOGw8e9OTNTDRsPkcR5wIrXxR6BAf11z2L22d9
'' SIG '' Vz41622NAUCNGoeW4g93TIm6OJz7jgKR2yIP5dA2qbg3
'' SIG '' RdAq/JaNwWBxM6WIsfbCBDCHW8PXL7J5EdiLZWKiihFm
'' SIG '' XX5/BXpzih96heXNKBDRPQIDAQABo4IBHTCCARkwEwYD
'' SIG '' VR0lBAwwCgYIKwYBBQUHAwMwHQYDVR0OBBYEFCZbPltd
'' SIG '' ll/i93eIf15FU1ioLlu4MA4GA1UdDwEB/wQEAwIHgDAf
'' SIG '' BgNVHSMEGDAWgBTLEejK0rQWWAHJNy4zFha5TJoKHzBW
'' SIG '' BgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jv
'' SIG '' c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNDb2RT
'' SIG '' aWdQQ0FfMDgtMzEtMjAxMC5jcmwwWgYIKwYBBQUHAQEE
'' SIG '' TjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jv
'' SIG '' c29mdC5jb20vcGtpL2NlcnRzL01pY0NvZFNpZ1BDQV8w
'' SIG '' OC0zMS0yMDEwLmNydDANBgkqhkiG9w0BAQUFAAOCAQEA
'' SIG '' D95ASYiR0TE3o0Q4abJqK9SR+2iFrli7HgyPVvqZ18qX
'' SIG '' J0zohY55aSzkvZY/5XBml5UwZSmtxsqs9Q95qGe/afQP
'' SIG '' l+MKD7/ulnYpsiLQM8b/i0mtrrL9vyXq7ydQwOsZ+Bpk
'' SIG '' aqDhF1mv8c/sgaiJ6LHSFAbjam10UmTalpQqXGlrH+0F
'' SIG '' mRrc6GWqiBsVlRrTpFGW/VWV+GONnxQMsZ5/SgT/w2at
'' SIG '' Cq+upN5j+vDqw7Oy64fbxTittnPSeGTq7CFbazvWRCL0
'' SIG '' gVKlK0MpiwyhKnGCQsurG37Upaet9973RprOQznoKlPt
'' SIG '' z0Dkd4hCv0cW4KU2au+nGo06PTME9iUgIzCCBLowggOi
'' SIG '' oAMCAQICCmECkkoAAAAAACAwDQYJKoZIhvcNAQEFBQAw
'' SIG '' dzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgUENBMB4XDTEyMDEwOTIy
'' SIG '' MjU1OVoXDTEzMDQwOTIyMjU1OVowgbMxCzAJBgNVBAYT
'' SIG '' AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH
'' SIG '' EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29y
'' SIG '' cG9yYXRpb24xDTALBgNVBAsTBE1PUFIxJzAlBgNVBAsT
'' SIG '' Hm5DaXBoZXIgRFNFIEVTTjpCOEVDLTMwQTQtNzE0NDEl
'' SIG '' MCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2Vy
'' SIG '' dmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
'' SIG '' ggEBAM1jw/eitUfZ+TmUU6xrj6Z5OCH00W49FTgWwXMs
'' SIG '' mY/74Dxb4aJMi7Kri7TySse5k1DRJvWHU7B6dfNHDxcr
'' SIG '' Zyxk62DnSozgi17EVmk3OioEXRcByL+pt9PJq6ORqIHj
'' SIG '' Py232OTEeAB5Oc/9x2TiIxJ4ngx2J0mPmqwOdOMGVVVJ
'' SIG '' yO2hfHBFYX6ycRYe4cFBudLSMulSJPM2UATX3W88SdUL
'' SIG '' 1HZA/GVlE36VUTrV/7iap1drSxXlN1gf3AANxa7q34FH
'' SIG '' +fBSrubPWqzgFEqmcZSA+v2wIzBg6YNgrA4kHv8R8uel
'' SIG '' VWKV7p9/ninWzUsKdoPwQwTfBkkg8lNaRLBRejkCAwEA
'' SIG '' AaOCAQkwggEFMB0GA1UdDgQWBBTNGaxhTZRnK/avlHVZ
'' SIG '' 2/BYAIOhOjAfBgNVHSMEGDAWgBQjNPjZUkZwCu1A+3b7
'' SIG '' syuwwzWzDzBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
'' SIG '' Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0
'' SIG '' cy9NaWNyb3NvZnRUaW1lU3RhbXBQQ0EuY3JsMFgGCCsG
'' SIG '' AQUFBwEBBEwwSjBIBggrBgEFBQcwAoY8aHR0cDovL3d3
'' SIG '' dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNyb3Nv
'' SIG '' ZnRUaW1lU3RhbXBQQ0EuY3J0MBMGA1UdJQQMMAoGCCsG
'' SIG '' AQUFBwMIMA0GCSqGSIb3DQEBBQUAA4IBAQBRHNbfNh3c
'' SIG '' gLwCp8aZ3xbIkAZpFZoyufNkENKK82IpG3mPymCps13E
'' SIG '' 5BYtNYxEm/H0XGGkQa6ai7pQ0Wp5arNijJ1NUVALqY7U
'' SIG '' v6IQwEfVTnVSiR4/lmqPLkAUBnLuP3BZkl2F7YOZ+oKE
'' SIG '' nuQDASETqyfWzHFJ5dod/288CU7VjWboDMl/7jEUAjdf
'' SIG '' e2nsiT5FfyVE5x8a1sUaw0rk4fGEmOdP+amYpxhG7IRs
'' SIG '' 7KkDCv18elIdnGukqA+YkqSSeFwreON9ssfZtnB931tz
'' SIG '' U7+q1GZQS/DJO5WF5cFKZZ0lWFC7IFSReTobB1xqVyiv
'' SIG '' Mcef58Md7kf9J9d/z3TcZcU/MIIFvDCCA6SgAwIBAgIK
'' SIG '' YTMmGgAAAAAAMTANBgkqhkiG9w0BAQUFADBfMRMwEQYK
'' SIG '' CZImiZPyLGQBGRYDY29tMRkwFwYKCZImiZPyLGQBGRYJ
'' SIG '' bWljcm9zb2Z0MS0wKwYDVQQDEyRNaWNyb3NvZnQgUm9v
'' SIG '' dCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMTAwODMx
'' SIG '' MjIxOTMyWhcNMjAwODMxMjIyOTMyWjB5MQswCQYDVQQG
'' SIG '' EwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
'' SIG '' BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
'' SIG '' cnBvcmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29k
'' SIG '' ZSBTaWduaW5nIFBDQTCCASIwDQYJKoZIhvcNAQEBBQAD
'' SIG '' ggEPADCCAQoCggEBALJyWVwZMGS/HZpgICBCmXZTbD4b
'' SIG '' 1m/My/Hqa/6XFhDg3zp0gxq3L6Ay7P/ewkJOI9VyANs1
'' SIG '' VwqJyq4gSfTwaKxNS42lvXlLcZtHB9r9Jd+ddYjPqnNE
'' SIG '' f9eB2/O98jakyVxF3K+tPeAoaJcap6Vyc1bxF5Tk/TWU
'' SIG '' cqDWdl8ed0WDhTgW0HNbBbpnUo2lsmkv2hkL/pJ0KeJ2
'' SIG '' L1TdFDBZ+NKNYv3LyV9GMVC5JxPkQDDPcikQKCLHN049
'' SIG '' oDI9kM2hOAaFXE5WgigqBTK3S9dPY+fSLWLxRT3nrAgA
'' SIG '' 9kahntFbjCZT6HqqSvJGzzc8OJ60d1ylF56NyxGPVjzB
'' SIG '' rAlfA9MCAwEAAaOCAV4wggFaMA8GA1UdEwEB/wQFMAMB
'' SIG '' Af8wHQYDVR0OBBYEFMsR6MrStBZYAck3LjMWFrlMmgof
'' SIG '' MAsGA1UdDwQEAwIBhjASBgkrBgEEAYI3FQEEBQIDAQAB
'' SIG '' MCMGCSsGAQQBgjcVAgQWBBT90TFO0yaKleGYYDuoMW+m
'' SIG '' PLzYLTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAf
'' SIG '' BgNVHSMEGDAWgBQOrIJgQFYnl+UlE/wq4QpTlVnkpDBQ
'' SIG '' BgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jv
'' SIG '' c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9taWNyb3Nv
'' SIG '' ZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEESDBGMEQG
'' SIG '' CCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
'' SIG '' b20vcGtpL2NlcnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNy
'' SIG '' dDANBgkqhkiG9w0BAQUFAAOCAgEAWTk+fyZGr+tvQLEy
'' SIG '' tWrrDi9uqEn361917Uw7LddDrQv+y+ktMaMjzHxQmIAh
'' SIG '' Xaw9L0y6oqhWnONwu7i0+Hm1SXL3PupBf8rhDBdpy6Wc
'' SIG '' IC36C1DEVs0t40rSvHDnqA2iA6VW4LiKS1fylUKc8fPv
'' SIG '' 7uOGHzQ8uFaa8FMjhSqkghyT4pQHHfLiTviMocroE6WR
'' SIG '' Tsgb0o9ylSpxbZsa+BzwU9ZnzCL/XB3Nooy9J7J5Y1ZE
'' SIG '' olHN+emjWFbdmwJFRC9f9Nqu1IIybvyklRPk62nnqaIs
'' SIG '' vsgrEA5ljpnb9aL6EiYJZTiU8XofSrvR4Vbo0HiWGFzJ
'' SIG '' NRZf3ZMdSY4tvq00RBzuEBUaAF3dNVshzpjHCe6FDoxP
'' SIG '' bQ4TTj18KUicctHzbMrB7HCjV5JXfZSNoBtIA1r3z6Nn
'' SIG '' CnSlNu0tLxfI5nI3EvRvsTxngvlSso0zFmUeDordEN5k
'' SIG '' 9G/ORtTTF+l5xAS00/ss3x+KnqwK+xMnQK3k+eGpf0a7
'' SIG '' B2BHZWBATrBC7E7ts3Z52Ao0CW0cgDEf4g5U3eWh++VH
'' SIG '' EK1kmP9QFi58vwUheuKVQSdpw5OPlcmN2Jshrg1cnPCi
'' SIG '' roZogwxqLbt2awAdlq3yFnv2FoMkuYjPaqhHMS+a3ONx
'' SIG '' PdcAfmJH0c6IybgY+g5yjcGjPa8CQGr/aZuW4hCoELQ3
'' SIG '' UAjWwz0wggYHMIID76ADAgECAgphFmg0AAAAAAAcMA0G
'' SIG '' CSqGSIb3DQEBBQUAMF8xEzARBgoJkiaJk/IsZAEZFgNj
'' SIG '' b20xGTAXBgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTAr
'' SIG '' BgNVBAMTJE1pY3Jvc29mdCBSb290IENlcnRpZmljYXRl
'' SIG '' IEF1dGhvcml0eTAeFw0wNzA0MDMxMjUzMDlaFw0yMTA0
'' SIG '' MDMxMzAzMDlaMHcxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
'' SIG '' EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4w
'' SIG '' HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xITAf
'' SIG '' BgNVBAMTGE1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQTCC
'' SIG '' ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ+h
'' SIG '' bLHf20iSKnxrLhnhveLjxZlRI1Ctzt0YTiQP7tGn0Uyt
'' SIG '' dDAgEesH1VSVFUmUG0KSrphcMCbaAGvoe73siQcP9w4E
'' SIG '' mPCJzB/LMySHnfL0Zxws/HvniB3q506jocEjU8qN+kXP
'' SIG '' CdBer9CwQgSi+aZsk2fXKNxGU7CG0OUoRi4nrIZPVVIM
'' SIG '' 5AMs+2qQkDBuh/NZMJ36ftaXs+ghl3740hPzCLdTbVK0
'' SIG '' RZCfSABKR2YRJylmqJfk0waBSqL5hKcRRxQJgp+E7VV4
'' SIG '' /gGaHVAIhQAQMEbtt94jRrvELVSfrx54QTF3zJvfO4OT
'' SIG '' oWECtR0Nsfz3m7IBziJLVP/5BcPCIAsCAwEAAaOCAasw
'' SIG '' ggGnMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCM0
'' SIG '' +NlSRnAK7UD7dvuzK7DDNbMPMAsGA1UdDwQEAwIBhjAQ
'' SIG '' BgkrBgEEAYI3FQEEAwIBADCBmAYDVR0jBIGQMIGNgBQO
'' SIG '' rIJgQFYnl+UlE/wq4QpTlVnkpKFjpGEwXzETMBEGCgmS
'' SIG '' JomT8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1p
'' SIG '' Y3Jvc29mdDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3Qg
'' SIG '' Q2VydGlmaWNhdGUgQXV0aG9yaXR5ghB5rRahSqClrUxz
'' SIG '' WPQHEy5lMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9j
'' SIG '' cmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
'' SIG '' L21pY3Jvc29mdHJvb3RjZXJ0LmNybDBUBggrBgEFBQcB
'' SIG '' AQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly93d3cubWlj
'' SIG '' cm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljcm9zb2Z0Um9v
'' SIG '' dENlcnQuY3J0MBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0G
'' SIG '' CSqGSIb3DQEBBQUAA4ICAQAQl4rDXANENt3ptK132855
'' SIG '' UU0BsS50cVttDBOrzr57j7gu1BKijG1iuFcCy04gE1CZ
'' SIG '' 3XpA4le7r1iaHOEdAYasu3jyi9DsOwHu4r6PCgXIjUji
'' SIG '' 8FMV3U+rkuTnjWrVgMHmlPIGL4UD6ZEqJCJw+/b85HiZ
'' SIG '' Lg33B+JwvBhOnY5rCnKVuKE5nGctxVEO6mJcPxaYiyA/
'' SIG '' 4gcaMvnMMUp2MT0rcgvI6nA9/4UKE9/CCmGO8Ne4F+tO
'' SIG '' i3/FNSteo7/rvH0LQnvUU3Ih7jDKu3hlXFsBFwoUDtLa
'' SIG '' FJj1PLlmWLMtL+f5hYbMUVbonXCUbKw5TNT2eb+qGHpi
'' SIG '' Ke+imyk0BncaYsk9Hm0fgvALxyy7z0Oz5fnsfbXjpKh0
'' SIG '' NbhOxXEjEiZ2CzxSjHFaRkMUvLOzsE1nyJ9C/4B5IYCe
'' SIG '' FTBm6EISXhrIniIh0EPpK+m79EjMLNTYMoBMJipIJF9a
'' SIG '' 6lbvpt6Znco6b72BJ3QGEe52Ib+bgsEnVLaxaj2JoXZh
'' SIG '' tG6hE6a/qkfwEm/9ijJssv7fUciMI8lmvZ0dhxJkAj0t
'' SIG '' r1mPuOQh5bWwymO0eFQF1EEuUKyUsKV4q7OglnUa2ZKH
'' SIG '' E3UiLzKoCG6gW4wlv6DvhMoh1useT8ma7kng9wFlb4kL
'' SIG '' fchpyOZu6qeXzjEp/w7FW1zYTRuh2Povnj8uVRZryROj
'' SIG '' /TGCBJAwggSMAgEBMIGQMHkxCzAJBgNVBAYTAlVTMRMw
'' SIG '' EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
'' SIG '' b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRp
'' SIG '' b24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNpZ25p
'' SIG '' bmcgUENBAhMzAAAAiFkOPFEf4mpnAAEAAACIMAkGBSsO
'' SIG '' AwIaBQCggbIwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
'' SIG '' AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
'' SIG '' IwYJKoZIhvcNAQkEMRYEFDCb68aYvJXTJk85te1S+jtL
'' SIG '' p6R3MFIGCisGAQQBgjcCAQwxRDBCoCSAIgBNAEQAVAAg
'' SIG '' AFUARABJAHYAMwAgAFQAbwBvAGwAawBpAHShGoAYaHR0
'' SIG '' cDovL3d3dy5taWNyb3NvZnQuY29tMA0GCSqGSIb3DQEB
'' SIG '' AQUABIIBAC2wt4LWetaiN5s5taPNIuONv/wy/ALEOHOl
'' SIG '' WeuIpfFOvB0FroigolElIoXt5yS0/HURqddV2/XaRGtp
'' SIG '' 4ArfLvig8dH4f45GqZGqJY47yLZ8DcbTM6a/rRY8mULM
'' SIG '' lIkoga+kyGIYCKzakA8BhjQhnUMEKxij2XcIjR9O94Je
'' SIG '' EcsdwrVMpawBQGBABytnryDRPfMx5Yma0k7QTZKHLpsh
'' SIG '' WZTE2vZsQcXpv1HgROTdu6q5vmvUrBQNe15WagmJcRyB
'' SIG '' 3H4S18KXgwrX+GtXwnS1DFBpr1/KQy64jirPGxxZUgLv
'' SIG '' jRkyw8WJzcmr2hto/b0tlSJM8RdTV4QkIXa4zKpaO8Ch
'' SIG '' ggIfMIICGwYJKoZIhvcNAQkGMYICDDCCAggCAQEwgYUw
'' SIG '' dzELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0
'' SIG '' b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1p
'' SIG '' Y3Jvc29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWlj
'' SIG '' cm9zb2Z0IFRpbWUtU3RhbXAgUENBAgphApJKAAAAAAAg
'' SIG '' MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZI
'' SIG '' hvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xMjA4MzAxOTU3
'' SIG '' MDJaMCMGCSqGSIb3DQEJBDEWBBQSsdjxpnzU2D5eVlFt
'' SIG '' THUnRymRgzANBgkqhkiG9w0BAQUFAASCAQBm0kyC9w3a
'' SIG '' ZP0pl4LoFNeXiaLocsnzlxwVi5kAPrz02kJhezNjxWsM
'' SIG '' oLKvnVYGnEFPNE2yPI7XPDJCfTjqSzyBCFs1AkhPnA0v
'' SIG '' 9Pl3TGn8aR7thx2sAvD9kNtEr1lmWtqlK8ZnAPPmRIXk
'' SIG '' czEIyns4hkA1+CMTnbP1h2VKE/ZkoOx05mmQ6bOyQaEL
'' SIG '' WXMc31LPXPND2k43gQ7WMg5jheUQgKj7sjpIzEt52jOc
'' SIG '' x6eGHOGZc58h0ORRLxRbz3K7bnWt3SrN06O97n0G0sWy
'' SIG '' fiShI4SClvWn7WRqBqKIWisJctT6T9Y7pHFQx0d2G2qs
'' SIG '' nttbeH2riP6tcsV6pD631Sbd
'' SIG '' End signature block
