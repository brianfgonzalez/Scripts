Set objArgs = WScript.Arguments

if (objArgs.count > 0) then 
  MyPos = InStr(objArgs(0), ":") 
  Sitecode =  wscript.arguments.item(0)
else 
  Wscript.echo("You must enter your sitecode as an argument! eg: exppdf S01") 
  Wscript.Quit(1) 
end if

Dim Shell 
Dim System 
Dim oFile 
Dim Flags(32) 
Set Shell = CreateObject("Wscript.Shell") 
Set System = CreateObject("Scripting.FileSystemObject") 
Set oFSO = CreateObject("Scripting.FileSystemObject") 
Const ForReading = 1 
Const ForWriting = 2 
CRLF = Chr(13) & Chr(10) 
winmgmt1 = "winmgmts:\\sago-sql\root\sms\site_" & sitecode 
'            SmsPath 
'            "\root\sms\site_sms"

'/////////////////////////////////////////////////////////////////////// //////// 
'//Echo your connection then get the object 
'/////////////////////////////////////////////////////////////////////// //////// 
'// oFile.WriteLine winmgmt1 
Set SystemSet = GetObject( winmgmt1 )

'/////////////////////////////////////////////////////////////////////// //////// 
'// Create Query String 
'/////////////////////////////////////////////////////////////////////// //////// 
strQuery = "select PackageID, Name, Version, Icon, Description,  " & _ 
           "LastRefreshTime, SourceSite, Manufacturer, Language, " & _ 
           "MIFFilename, MIFName, MIFPublisher, MIFVersion from  " & _ 
           "SMS_Package" 
' where PackageID = '" & SmsPackage  & "'"

'/////////////////////////////////////////////////////////////////////////////// 
'// Create Query Connection 
'/////////////////////////////////////////////////////////////////////////////// 
Set objEnumerator = SystemSet.ExecQuery(strQuery)

'/////////////////////////////////////////////////////////////////////// /////// 
'// Loop through all results and echo to screen 
'/////////////////////////////////////////////////////////////////////// /////// 
foldername = InputBox( "Enter Folder Name eg c:\temp ", "Save as...", foldername) 
for each instance in objEnumerator 
  fname = foldername &"\"& instance.PackageID &".sms"

  Set oFile = System.OpenTextFile(fname, ForWriting, True) 
  WScript.Echo "Creating " & fname &" for " & instance.Name  

  oFile.WriteLine "" 
  oFile.WriteLine "[PDF]" 
  oFile.WriteLine "VERSION=2.0" 
  oFile.WriteLine "" 
  oFile.WriteLine "[Package Definition]"

'// NAME - Required - up to 50 characters 
  oFile.WriteLine "Name=" & instance.Name  

'// VERSION - up to 32 characters 
  if (len(instance.Version ) > 0) then 
     oFile.WriteLine "Version=" & instance.Version 
  end if

'// TODO: ICON comes back as actual Icon data.  If the data exists, 
'// save in ICO file (?), then put icon file name in value. 
'// ICON - file name of icon file (must be in same dir as PDF when you import) 
'//    Icon returned as an array of Variants 
'  wscript.echo "Type " & Vartype(instance.icon) 
'  if (instance.Icon <> NULL) then 
'         oFile.WriteLine "Icon=" & instance.Icon 
'  end if

'// PUBLISHER - Required - up to 32 characters 
 if (len(instance.Manufacturer) = 0) then 
        oFile.WriteLine "Publisher=unknown" 
  Else 
        oFile.WriteLine "Publisher=" & instance.Manufacturer 
 end if

'// LANGUAGE - Required 
 if (len(instance.Language) = 0) then 
        oFile.WriteLine "Language=English" 
  Else 
        oFile.WriteLine "Language=" & instance.Language 
 end if

'// COMMENT - not required, up to 127 charaters 
  if (len(instance.Description) > 0) then 
     oFile.WriteLine "Comment=" & instance.Description 
  end if

'// MIFFILENAME 
  if (len(instance.MIFFilename) > 0) then 
     oFile.WriteLine "MIFfilename=" & instance.MIFFilename 
  end if

'// MIFNAME 
  if (len(instance.MIFName) > 0) then 
     oFile.WriteLine "MIFName=" & instance.MIFName 
  end if

'// MIFPUBLISHER 
  if (len(instance.MIFPublisher) > 0) then 
    oFile.WriteLine "MIFPublisher=" & instance.MIFPublisher 
  end if

'// MIFVERSION 
  if (len(instance.MIFVersion) > 0) then 
     oFile.WriteLine "MIFVersion=" & instance.MIFVersion 
  end if

'/////////////////////////////////////////////////////////////////////// //////// 
  prgQuery = "select PackageID, ProgramName from SMS_Program where PackageID = '" & instance.PackageID & "'" 
  Set prgEnumerator = SystemSet.ExecQuery(prgQuery)

'/////////////////////////////////////////////////////////////////////// //////// 
'// Create Programs= line by putting program names in comma delimited list 
'/////////////////////////////////////////////////////////////////////// //////// 
  proglist = "" 
  for each prog in prgEnumerator 
     if (len(proglist) > 0) then 
        proglist = proglist & ", " & prog.ProgramName 
     else 
        proglist = prog.ProgramName 
     end if 
  next 
  oFile.WriteLine "Programs=" & proglist

'/////////////////////////////////////////////////////////////////////// //////// 
'//  Loop through each program and output parameters 
'/////////////////////////////////////////////////////////////////////// //////// 
  for each prog in prgEnumerator

     set progobj = SystemSet.Get(prog.Path_)

'/////////////////////////////////////////////////////////////////////// //////// 
'//  parse ProgramFlags to attributes below 
'/////////////////////////////////////////////////////////////////////// //////// 
     For loopcounter = 12 To 29 Step 1 
       If ((progobj.ProgramFlags And 2 ^ loopcounter) = (2 ^ loopcounter)) Then 
         Flags(loopcounter) = 1 
       Else 
         Flags(loopcounter) = 0 
       End If 
     Next '// for loopcounter

     oFile.WriteLine ""

'// PROGRAMNAME 
     oFile.WriteLine "[" & progobj.ProgramName & "]"

'// NAME 
     oFile.WriteLine "Name=" & progobj.ProgramName

'// ICON 
'     if (len(progobj.Icon) > 0) then 
'       oFile.WriteLine "Icon=" & progobj.Icon 
'     end if

'// COMMENT 
     if (len(progobj.Description) > 0) then 
        oFile.WriteLine "Comment=" & progobj.Description 
     end if

'// COMMANDLINE 
     oFile.WriteLine "CommandLine=" & progobj.CommandLine

'// STARTIN 
     if (len(progobj.WorkingDirectory) > 0) then 
        oFile.WriteLine "StartIn=" & progobj.WorkingDirectory 
     end if

'// RUN  - specifies run mode for program 
     if Flags(22) = 1 then 
        oFile.WriteLine "Run=Minimized" 
     elseif Flags(23) = 1 then 
        oFile.WriteLine "Run=Maximized" 
     elseif Flags(24) = 1 then 
        oFile.WriteLine "Run=Hidden" 
     else 
        oFile.WriteLine "Run=Normal" 
     end if

'// AFTERRUNNING - note, if entry missing, no action performed 
     if Flags(18) = 1 then 
        oFile.WriteLine "AfterRunning=ProgramRestart" 
     elseif Flags(19) = 1 then 
        oFile.WriteLine "AfterRunning=SMSRestart" 
     elseif Flags(25) = 1 then 
        oFile.WriteLine "AfterRunning=SMSLogoff" 
     end if

'// ESTIMATEDDISKSPACE - if entry missing defaults to 'UNKNOWN', include KB or MB. 
     if (len(progobj.DiskSpaceReq) > 0) then 
        oFile.WriteLine "EstimatedDiskSpace=" & progobj.DiskSpaceReq 
     end if

'// ESDTIMATEDRUNTIME - in minutes, if entry missing defaults to 
'UNKNOWN' 
     if (len(progobj.Duration) > 0) then 
        oFile.WriteLine "EstimatedRunTime=" & progobj.Duration 
     end if

'// ENABLERUNTIMEMONITORING - notifies user if time exceeded by 15 minutes 
     if Flags(28) = 1 then 
        oFile.WriteLine "EnableRunTimeMonitoring=True" 
     else 
        oFile.WriteLine "EnableRunTimeMonitoring=False" 
     end if

'// ADDITIONALPROGRAMREQUIREMENTS - comment seen by administrators and users 
     if (len(progobj.Requirements) > 0) then 
        oFile.WriteLine "AdditionalProgramRequirements=" & progobj.Requirements 
     end if

'// CANRUNWHEN - application install dependent on user logged on or not. 
     if Flags(14) = 1 then 
        oFile.WriteLine "CanRunWhen=UserLoggedOn" 
     elseif Flags(17) = 1 then 
        oFile.WriteLine "CanRunWhen=NoUserLoggedOn" 
     else 
        oFile.WriteLine "CanRunWhen=AnyUserStatus" 
     end if

'// USERINPUTREQUIRED - specify whether user must interact with program 
     if Flags(14) = 1 then 
        oFile.WriteLine "UserInputRequired=False" 
     else 
        oFile.WriteLine "UserInputRequired=True" 
     end if

'// ADMINRIGHTSREQUIRED - specify program elevated to administrator 
     if Flags(15) = 1 then 
        oFile.WriteLine "AdminRightsRequired=True" 
     end if

'// USEINSTALLACCOUNT - use Windows NT Client Software installation account 
     if Flags(26) = 1 then 
        oFile.WriteLine "UseInstallAccount=True" 
     end if

'// DRIVELETTERCONNECTION - program requires a drive letter connection to package share 
     if Flags(20) = 1 then 
        oFile.WriteLine "DriveLetterConnection=False" 
     else 
        oFile.WriteLine "DriveLetterConnection=True" 
     end if

'// SPECIFYDRIVE - dive letter to connect as (if DRIVELETTERCONNECTION True) 
     if (len(progobj.DriveLetter) > 0) then 
        oFile.WriteLine "SpecifyDrive=" & progobj.DriveLetter 
     end if

'// RECONNECTDRIVEATLOGON - makes drive connection persistent 
     if Flags(21) = 1 then 
        oFile.WriteLine "ReconnectDriveAtLogon=True" 
     end if

'// DEPENDENTPROGRAM - another program in this package to run first 
	if (len(progobj.DependentProgram) > 0) And Not (instr(progobj.DependentProgram, progobj.PackageID)) Then
		strDep = progobj.DependentProgram
		strDep = right(strDep,Len(strDep) - 1 - inStr(strDep,";;"))
		'MsgBox progobj.DependentProgram & " -> " & strDep
		oFile.WriteLine "DependentProgram=" & strDep
	end If

'// ASSIGNMENT - assign to the first or every user of machine 
     if Flags(16) = 1 then 
        oFile.WriteLine "Assignment=EveryUser" 
     else 
        oFile.WriteLine "Assignment=FirstUser" 
     end if

'// DISABLED - Whether program can be run and/or displayed to clients 
     if Flags(12) = 1 then 
        oFile.WriteLine "Disabled=True" 
     end if

'// REMOVEPROGRAM - whether program uninstalled when no longer advertised. 
     if Flags(29) = 1 then 
        oFile.WriteLine "RemoveProgram=True" 
        '  requires entry for UninstallKey= 
     end if

'// UNINSTALLKEY - key containing uninstall information for package 
     if (len(progobj.RemovalKey) > 0) then 
        oFile.WriteLine "UninstallKey=" & progobj.RemovalKey 
     end if

'/////////////////////////////////////////////////////////////////////// //////// 
'// Logic for Platform requirements 
'/////////////////////////////////////////////////////////////////////// //////// 
     if Flags(27) = 0 then ' Only execute if ANY_PLATFORM(27) is False 
       progSupp = "" 
       progPlatform = "" 
       progMinMax = ""

       for each progos in progobj.SupportedOperatingSystems 
           progPlatform = progos.name & " (" & progos.Platform & ")" 
           if (Instr(progSupp, progPlatform) = 0) then 
              if (len(progSupp) > 0) then 
                 progSupp = progSupp & ", " 
              end if 
              progSupp = progSupp & progPlatform 
              progCount = 1 
              progMinMax = progMinMax & progPlatform & "MinVersion" &  progCount & "=" & progos.MinVersion & CRLF 
              progMinMax = progMinMax & progPlatform & "MaxVersion" & progCount & "=" & progos.MaxVersion & CRLF 
           else 
              progCount = progCount + 1 
              progMinMax = progMinMax & progPlatform & "MinVersion" & progCount & "=" & progos.MinVersion & CRLF 
              progMinMax = progMinMax & progPlatform & "MaxVersion" & progCount & "=" & progos.MaxVersion & CRLF 
           end if 
       Next

       oFile.WriteLine "SupportedClients=" & progSupp 
       oFile.WriteLine progMinMax

     end if ' ANY_PLATFORM(27)

  Next ' program

  oFile.WriteLine "" 
  oFile.WriteLine "" 
  oFile.WriteLine ""

  '// Warning, the next line will refresh the files in your package 
  '// This is a cool trick for an unattended refresh! 
  '//    RetCode = instance.RefreshPkgSource

  oFile.close 
Next ' package

Wscript.Quit(0)