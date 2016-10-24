rem USE AT OWN RISK AS IS WITHOUT WARRANTY OF ANY KIND !!!!!

rem Sections

rem Basic recommendations
rem Software recommendations

rem Remove various folders, startup entries and policies
rem Restore essential startup entries

rem Windows 0
rem Windows Basics
rem Windows Defender
rem Windows Desktop
rem Windows Drivers
rem Windows Error Reporting
rem Windows Explorer
rem Windows Logging
rem Windows Network
rem Windows Notifications
rem Windows Optimizations
rem Windows Policies
rem Windows Privacy
rem Windows Scheduled Tasks
rem Windows Services
rem Windows Shell
rem Windows Updates
rem Windows Waypoint

rem ========================= Basic recommendations =========================

rem Link your Microsoft Account to Windows 10 Activation Digital License
rem www.tenforums.com/tutorials/55398-microsoft-account-link-digital-license-windows-10-pc.html

rem Network Connection - all adapters
rem Delete all network protocols except IPv4
rem Uncheck IPv6

rem Privacy Options
rem Turn Off Everything (Some updates keep enabling some settings, so you need to keep checking)

rem Check for Browser Leaks- www.browserleaks.com
rem Check for Hacked Info - www.leakedsource.com

rem Windows 10 Forums - www.tenforums.com
rem Windows 10 Support - technet.microsoft.com/en-us/windows/support-windows-10.aspx

rem ========================= Software recommendations =========================

rem Recommended free cleanup software
rem CCleaner - www.piriform.com/ccleaner/builds
rem Wise Care - www.wisecleaner.com/wise-care-365.html
rem Wise Program Uninstaller - www.wisecleaner.com/wise-program-uninstaller.html

rem Recommended free security cleanup software
rem Dr.Web CureIt! - free.drweb.com/download+cureit+free
rem Emsisoft Emergency Kit - www.emsisoft.com/en/software/eek
rem Guide - malwaretips.com/blogs/malware-removal-guide-for-windows
rem Help - www.bleepingcomputer.com/forums/t/182397/am-i-infected-what-do-i-do-how-do-i-get-help-who-is-helping-me

rem Recommended free security software
rem Avast Free Antivirus - www.avast.com/free-antivirus-download
rem Bitdefender Antivirus Free Edition - www.bitdefender.com/solutions/free.html?target=1

rem Recommended free software replacement for Windows 10 apps
rem Browser / Yandex.Browser - browser.yandex.com
rem Computer Management / www.nirsoft.net/utils/index.html
rem File Archiver / 7-zip x64 - www.7-zip.org
rem Disc Space Manager / TreeSize Free - www.jam-software.com/treesize_free
rem DNS Benchmark / Namebench - code.google.com/archive/p/namebench/downloads
rem Disc to MKV / MakeMKV - www.makemkv.com/download
rem Driver Updates / Driver Easy - www.drivereasy.com
rem Hardware Information / HWiNFO x64 - www.hwinfo.com/download.php
rem Image Viewer / XnView - www.xnview.com/en/xnview/#downloads
rem Media Player / VLC x64 - www.videolan.org/vlc
rem Network Optimization / TCP Optimizer - www.speedguide.net/downloads.php / www.tenforums.com/network-sharing/2806-slow-network-throughput-windows-10-a.html#post553305
rem Network Settings / NetSetMan - www.netsetman.com/en/freeware
rem Office Suite / WPS Office - wps.com/office-free
rem Online Radio / RadioSure - www.radiosure.com/downloadz/downloadz-select
rem Password Manager (Offline) / KeePass - keepass.info/download.html
rem PDF Viewer / PDF xChange Editor x64 - www.tracker-software.com/product/pdf-xchange-editor
rem Remote Support / TeamViewer - www.teamviewer.com/en/download/windows
rem Startup Manager / Autoruns x64 - technet.microsoft.com/en-us/sysinternals/bb963902.aspx
rem Systen Restore / RollBack Home Edition - www.horizondatasys.com/en/products_and_solutions.aspx?ProductId=40#Features
rem Task Manager / Process Hacker x64 - wj32.org/processhacker/index.php
rem Video Thumbnail Previews / K-Lite Basic Codec Pack - www.codecguide.com/download_kl.htm
rem Windows Updates / Windows Update MiniTool - forums.mydigitallife.info/threads/64939-Windows-Update-MiniTool

rem ========================= Remove various files, folders, startup entries and policies =========================

rem Remove randomly generated files/folders by installers
taskkill /im ktpcntr.exe /f
del "%USERPROFILE%\AppData\Local\Kingsoft\WPS Office\10.1.0.5775\office6\ktpcntr.exe" /s /f /q
taskkill /im wpscenter.exe /f
del "%USERPROFILE%\AppData\Local\Kingsoft\WPS Office\10.1.0.5775\office6\wpscenter.exe" /s /f /q
taskkill /im wpscloudsvr.exe /f
del "%USERPROFILE%\AppData\Local\Kingsoft\WPS Office\10.1.0.5775\office6\wpscloudsvr.exe" /s /f /q
rd "%SystemDrive%\AMD" /s /q
rd "%SystemDrive%\drivers" /s /q
rd "%SystemDrive%\Users\defaultuser0" /s /q
rd "%USERPROFILE%\AppData\Local\Kingsoft\WPS Office\10.1.0.5775\wtoolex" /s /q

rem Remove Cortana to get rid of SearchUI.exe (to restore run "sfc /scannow")
rd "%WINDIR%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" /s /q

rem Remove Microsoft Synchronization Manager to prevent it from running at every startup (to restore run "sfc /scannow")
taskkill /im mobsync.exe /f
del "%WINDIR%\System32\mobsync.exe" /s /f /q

rem Remove Windows Powershell (to restore run "sfc /scannow")
rem threatpost.com/fileless-powerware-ransomware-found-on-healthcare-network/116998
rem www.invincea.com/2016/06/hash-factory-new-cerber-ransomware-morphs-every-15-seconds
rem news.softpedia.com/news/windows-event-viewer-abused-to-bypass-uac-on-windows-7-and-windows-10-507318.shtml
rd "%ProgramFiles%\WindowsPowerShell" /s /q
rd "%ProgramFiles(x86)%\WindowsPowerShell" /s /q
rd "%WINDIR%\System32\WindowsPowerShell" /s /q
rd "%WINDIR%\SysWOW64\WindowsPowerShell" /s /q

rem Remove Startup Folders
del "%SystemDrive%\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\*" /s /f /q
del "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\*" /s /f /q

reg delete "HKCU\Software\Microsoft\Command Processor" /v "AutoRun" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\RunOnce" /f
reg delete "HKCU\Software\Policies" /f
reg delete "HKLM\Software\Microsoft\Command Processor" /v "AutoRun" /f
reg delete "HKLM\Software\Microsoft\Policies" /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved" /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies" /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce" /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Terminal Server" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Windows" /v "AppInit_DLLs" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "VMApplet" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\AlternateShells" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Shell" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Taskman" /f
reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit" /f
reg delete "HKLM\Software\Policies" /f
reg delete "HKLM\Software\WOW6432Node\Microsoft\Policies" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Run" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\RunOnce" /f
reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies" /f
reg delete "HKLM\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Windows" /v "AppInit_DLLs" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "VMApplet" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon\AlternateShells" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon\Shell" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon\Taskman" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit" /f
reg delete "HKLM\Software\WOW6432Node\Policies" /f
reg delete "HKLM\System\CurrentControlSet\Control\Keyboard Layout" /v "Scancode Map" /f
reg delete "HKLM\System\CurrentControlSet\Control\SafeBoot" /v "AlternateShell" /f
reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "BootExecute" /f
reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "Execute" /f
reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "SETUPEXECUTE" /f
reg delete "HKLM\System\CurrentControlSet\Control\Terminal Server\Wds\rdpwd" /v "StartupPrograms" /f

rem ========================= Restore essential startup entries =========================

rem Run bcdedit command to check for the current status / Yes = True / No = False
rem msdn.microsoft.com/en-us/library/windows/hardware/ff542202(v=vs.85).aspx
bcdedit /deletevalue {current} safeboot
bcdedit /deletevalue {default} safeboot
bcdedit /set {default} advancedoptions false
bcdedit /set {default} bootems no
bcdedit /set {default} bootmenupolicy legacy
bcdedit /set {default} bootstatuspolicy DisplayAllFailures
bcdedit /set {default} recoveryenabled no
bcdedit /set {bootmgr} displaybootmenu no
bcdedit /set {current} advancedoptions false
bcdedit /set {current} bootems no
bcdedit /set {current} bootmenupolicy legacy
bcdedit /set {current} bootstatuspolicy DisplayAllFailures
bcdedit /set {current} recoveryenabled no

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "EvtMgr6" /t REG_SZ /d "C:\Program Files\Logitech\SetPointP\SetPoint.exe /launchGaming" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "explorer.exe" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Userinit" /t REG_SZ /d "C:\Windows\System32\userinit.exe," /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "Shell" /t REG_SZ /d "explorer.exe" /f
reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "BootExecute" /t REG_MULTI_SZ /d "autocheck autochk *" /f
reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "SETUPEXECUTE" /t REG_MULTI_SZ /d "" /f

rem ========================= Windows 0 =========================

rem Things needed to be done only once at day zero

rem Disable Pagefile - tunecomp.net/win10-page-file-disable
rem Disable Remote Desktop Connection - www.thewindowsclub.com/remote-desktop-connection-windows
rem Disable Security Accounts Manager service - services.msc
rem Disable Turning Off HDD - http://www.thewindowsclub.com/prevent-hard-drive-going-sleep-windows

rem You need to take ownership of the file/folder beforehand - youtube.com/watch?v=x7gjZMvQHu4
rem tenforums.com/tutorials/3841-take-ownership-add-context-menu-windows-10-a.html but you still need to 
rem You might still need to Allow user Full Control - Properties - Security - Edit - Select User (or Add, if missing) - Select Allow Full Control
rem %SystemDrive%\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup
rem %SystemDrive%\Users\defaultuser0"
rem %ProgramFiles%\WindowsPowerShell
rem %ProgramFiles(x86)%\WindowsPowerShell
rem %WINDIR%\System32\mobsync.exe
rem %WINDIR%\System32\WindowsPowerShell
rem %WINDIR%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy
rem %WINDIR%\SysWOW64\WindowsPowerShell

rem You need to take ownership of the registry key beforehand - youtube.com/watch?v=M1l5ifYKefg
rem "HKCR\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder"

rem msdn.microsoft.com/en-us/windows/hardware/commercialize/manufacture/desktop/enable-or-disable-windows-features-using-dism
rem Dism /Online /Get-Features
rem Dism /Online /Disable-Feature /FeatureName:Internet-Explorer-Optional-amd64
rem Dism /Online /Disable-Feature /FeatureName:MediaPlayback /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:MicrosoftWindowsPowerShellV2 /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:MicrosoftWindowsPowerShellV2Root /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:Printing-PrintToPDFServices-Features /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:Printing-XPSServices-Features /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:SearchEngine-Client-Package /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:WCF-TCP-PortSharing45 /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:WorkFolders-Client /Quiet /NoRestart
rem Dism /Online /Disable-Feature /FeatureName:Xps-Foundation-Xps-Viewer /Quiet /NoRestart
rem Dism /Online /Enable-Feature /FeatureName:NetFx3 /All

rem ========================= Windows Basics =========================

rem Command-line reference A-Z - technet.microsoft.com/en-us/library/bb490890.aspx

rem 5 - 5 secs / Time to display list of operating systems
bcdedit /timeout 5

rem Delete Windows Sounds (Permanently)
reg delete "HKCU\AppEvents\Schemes\Apps" /f

rem Set Formats to Metric
reg add "HKCU\Control Panel\International" /v "iDigits" /t REG_SZ /d "2" /f
reg add "HKCU\Control Panel\International" /v "iLZero" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\International" /v "iMeasure" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\International" /v "iNegNumber" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\International" /v "iPaperSize" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\International" /v "iTLZero" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\International" /v "sDecimal" /t REG_SZ /d "," /f
reg add "HKCU\Control Panel\International" /v "sNativeDigits" /t REG_SZ /d "0123456789" /f
reg add "HKCU\Control Panel\International" /v "sNegativeSign" /t REG_SZ /d "-" /f
reg add "HKCU\Control Panel\International" /v "sPositiveSign" /t REG_SZ /d "" /f
reg add "HKCU\Control Panel\International" /v "NumShape" /t REG_SZ /d "1" /f

rem 244 - Set Location to United States (for the best Windows and Store experience) / 143 - Slovakia
reg add "HKCU\Control Panel\International\Geo" /v "Nation" /t REG_SZ /d "143" /f

rem Set Time to 24h / Monday
reg add "HKCU\Control Panel\International" /v "iCalendarType" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\International" /v "iDate" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\International" /v "iFirstDayOfWeek" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\International" /v "iFirstWeekOfYear" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\International" /v "iTime" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\International" /v "iTimePrefix" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\International" /v "sDate" /t REG_SZ /d "-" /f
reg add "HKCU\Control Panel\International" /v "sList" /t REG_SZ /d "," /f
reg add "HKCU\Control Panel\International" /v "sLongDate" /t REG_SZ /d "d MMMM, yyyy" /f
reg add "HKCU\Control Panel\International" /v "sMonDecimalSep" /t REG_SZ /d "." /f
reg add "HKCU\Control Panel\International" /v "sMonGrouping" /t REG_SZ /d "3;0" /f
reg add "HKCU\Control Panel\International" /v "sMonThousandSep" /t REG_SZ /d "," /f
reg add "HKCU\Control Panel\International" /v "sShortDate" /t REG_SZ /d "dd-MMM-yy" /f
reg add "HKCU\Control Panel\International" /v "sTime" /t REG_SZ /d ":" /f
reg add "HKCU\Control Panel\International" /v "sTimeFormat" /t REG_SZ /d "HH:mm:ss" /f
reg add "HKCU\Control Panel\International" /v "sShortTime" /t REG_SZ /d "HH:mm" /f
reg add "HKCU\Control Panel\International" /v "sYearMonth" /t REG_SZ /d "MMMM yyyy" /f

rem Set Time Zone
tzutil /s "Central Europe Standard Time"

rem When windows detects communicarions activity / 0 - Mute all other sounds / 1 - Reduce all other by 80% / 2 - Reduce all other by 50% / 3 - Do nothing
reg add "HKCU\Software\Microsoft\Multimedia\Audio" /v "UserDuckingPreference" /t REG_DWORD /d "3" /f

rem 1 - Enable Automatic Restart on System Failure
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "AutoReboot" /t REG_DWORD /d "1" /f

rem System Info
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Logo" /t REG_SZ /d "D:\Software\Temp\Pics\Mikai.bmp" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Manufacturer" /t REG_SZ /d "TairikuOkami" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\OEMInformation" /v "SupportHours" /t REG_SZ /d "None" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\OEMInformation" /v "SupportPhone" /t REG_SZ /d "None" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\OEMInformation" /v "SupportURL" /t REG_SZ /d "www.facebook.com/tairikuokami" /f

rem Enable System restore and Set the size
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableSR" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore" /v "DisableConfig" /f
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SPP\Clients" /v " {09F7EDC5-294E-4180-AF6A-FB0E6A0E9513}" /t REG_MULTI_SZ /d "1" /f
schtasks /Change /TN "Microsoft\Windows\SystemRestore\SR" /Enable
vssadmin Resize ShadowStorage /For=C: /On=C: /Maxsize=5GB
sc config wbengine start= demand
sc config swprv start= demand
sc config vds start= demand
sc config VSS start= demand

rem Replace default Task Manager with Process Hacker (must be installed prior to use)
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v "Debugger" /t REG_SZ /d "\"C:\Program Files\Process Hacker 2\ProcessHacker.exe\"" /f
reg add "HKLM\Software\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v "Debugger" /t REG_SZ /d "\"C:\Program Files\Process Hacker 2\ProcessHacker.exe\"" /f

rem Computer Name - Z50-75 (Computer name should not be longer than 15 characters)
reg add "HKLM\System\CurrentControlSet\Control\ComputerName\ActiveComputerName" /v "ComputerName" /t REG_SZ /d "Z50-75" /f
reg add "HKLM\System\CurrentControlSet\Control\ComputerName\ComputerName" /v "ComputerName" /t REG_SZ /d "Z50-75" /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "Hostname" /t REG_SZ /d "Z50-75" /f
reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters" /v "NV Hostname" /t REG_SZ /d "Z50-75" /f

rem 5 - 5 secs / Delay Chkdsk startup time at OS Boot
reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "AutoChkTimeout" /t REG_DWORD /d "5" /f

rem ========================= Windows Defender =========================

rem 1 - Disable Real-time protection
reg add "HKLM\Software\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f

rem Disable WD Services
reg add "HKLM\System\CurrentControlSet\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\System\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\System\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f
reg add "HKLM\System\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f

rem Remove WD context menu
reg delete "HKCR\*\shellex\ContextMenuHandlers\EPP" /f
reg delete "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /f
reg delete "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /f

rem ========================= Windows Desktop =========================

rem 3 - Automatically Pick a Color from your Background
reg add "HKCU\Control Panel\Desktop" /v "AutoColorization" /t REG_SZ /d "1" /f

rem 0 - No screen saver is selected / 1 - A screen saver is selected
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveActive" /t REG_SZ /d "1" /f

rem Specifies whether the screen saver is password-protected / 0 - No / 1 - Yes
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaverIsSecure" /t REG_SZ /d "0" /f

rem Specifies in seconds how long the System remains idle before the screen saver starts
reg add "HKCU\Control Panel\Desktop" /v "ScreenSaveTimeOut" /t REG_SZ /d "250" /f

rem Specifies in milliseconds how long the System waits for user processes to end after the user clicks the End Task command button in Task Manager
reg add "HKCU\Control Panel\Desktop" /v "SCRNSAVE.EXE" /t REG_SZ /d "C:\Windows\System32\Mystify.scr" /f

rem Wallpaper Location
reg add "HKCU\Control Panel\Desktop" /v "Wallpaper" /t REG_SZ /d "D:\Software\Temp\Pics\Wallpaper.jpg" /f

rem 0 - Center the bitmap on the desktop / 2 - Stretch the bitmap vertically and horizontally to fit the desktop / 10 - Fill / 6 - Fit / 2 - Stretch / 0 - Tile/Center
reg add "HKCU\Control Panel\Desktop" /v "WallpaperStyle" /t REG_SZ /d "2" /f

rem 0 - Disable Game DVR and Game Bar / Disable the message "Press Win + G to open Game bar" / "Press Win + G to record a clip"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /t REG_DWORD /d "0" /f

rem 0 - Always show all icons and notifications on the taskbar / 1 - Hide Inactive Icons
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "EnableAutoTray" /t REG_DWORD /d "0" /f

rem Combine taskbar buttons / 0 - Alwayshide labels / 1 - When taskbar is full / 2 - Never
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d "2" /f

rem Hide Control Panel
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" /t REG_DWORD /d "1" /f

rem Hide Network
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /t REG_DWORD /d "1" /f

rem Hide Recycle Bin
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d "1" /f

rem Hide This PC
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d "1" /f

rem Hide User's Files
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /t REG_DWORD /d "1" /f

rem 0 - Disable / 1 - Enable (Default)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableCursorSuppression" /t REG_DWORD /d "0" /f

rem 0 - Disable Bing Search
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f

rem 0 - Disable Cortana in Taskbar search
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f

rem 0 - Hide Taskbar search / 1 - Show search icon / 2 - Show search box
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f

rem 1 - Disable/Hide Action Center System Tray Icon in Taskbar
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f

rem 1 - Disable/Hide Action Network System Tray Icon in Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCANetwork" /t REG_DWORD /d "1" /f

rem 1 - Disable/Hide Action Power System Tray Icon in Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAPower" /t REG_DWORD /d "1" /f

rem 1 - Disable/Hide Volume System Tray Icon in Taskbar
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAVolume" /t REG_DWORD /d "1" /f

rem 1 - Show color on Start, taskbar, and action center
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "ColorPrevalence" /t REG_DWORD /d "1" /f

rem 1 - Show color on title bar
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "ColorPrevalence" /t REG_DWORD /d "1" /f

rem ========================= Windows Drivers =========================

rem Specifies how the System responds when a user tries to install device driver files that are not digitally signed / 00 - Ignore / 01 - Warn / 02 - Block
reg add "HKLM\Software\Microsoft\Driver Signing" /v "Policy" /t REG_BINARY /d "01" /f

rem 1 - Prevent device metadata retrieval from the Internet/ Do not automatically download manufacturers’ apps and custom icons available for your devices
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Device Metadata" /v "PreventDeviceMetadataFromNetwork" /t REG_DWORD /d "1" /f 
schtasks /Change /TN "Microsoft\Windows\Device Setup\Metadata Refresh" /Disable

rem Do you want Windows to download driver Software / 0 - Never / 1 - Allways / 2 - Install driver Software, if it is not found on my computer
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d "0" /f

rem ========================= Windows Error Reporting =========================

rem 1 - Disable Windows Error Reporting (WER)
reg add "HKCU\Software\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d "1" /f

rem 1 - Disable WER sending second-level data
reg add "HKCU\Software\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v "DontSendAdditionalData" /t REG_DWORD /d "1" /f

rem 1 - Disable WER crash dialogs, popups
reg add "HKCU\Software\Microsoft\Windows\Windows Error Reporting" /v "DontShowUI" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v "DontShowUI" /t REG_DWORD /d "1" /f

rem 1 - Disable WER logging
reg add "HKCU\Software\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\Windows Error Reporting" /v "LoggingDisabled" /t REG_DWORD /d "1" /f

rem ========================= Windows Explorer =========================

rem Remove Network from Navigation Panel
rem You need to take ownership of the registry key beforehand - youtube.com/watch?v=M1l5ifYKefg
reg add "HKCR\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}\ShellFolder" /v "Attributes" /t REG_DWORD /d "2962489444" /f

rem 0 - Remove OneDrive from Windows Explorer
reg "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f

rem Folder Views remember Apply to Folders
reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" /v "FolderType" /t REG_SZ /d "NotSpecified" /f

rem 0 - All of the components of Windows Explorer run a single process / 1 - All instances of Windows Explorer run in one process and the Desktop and Taskbar run in a separate process
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "DesktopProcess" /t REG_DWORD /d "1" /f

rem 2 - Underline icon titles consistent with my browser / 3 - Underline icon titles only when I point at them
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "IconUnderline" /t REG_DWORD /d "2" /f

rem 1 - Disable Previous Versions Tab
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "NoPreviousVersionsPage" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "NoPreviousVersionsPage" /t REG_DWORD /d "1" /f

rem Single-click to open an item
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShellState" /t REG_BINARY /d "2400000017a8000000000000000000000000000001000000130000000000000073000000" /f

rem 0 - Do not show Frequent folders in Quick Access
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowFrequent" /t REG_DWORD /d "0" /f

rem 0 - Do not show Recent folders in Quick Access
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "ShowRecent" /t REG_DWORD /d "0" /f

rem 1 - Navigation Panel Expand to Current Folder
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "NavPaneExpandToCurrentFolder" /t REG_DWORD /d "0" /f

rem 0 - Do not hide extensions for known file types
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f

rem 1 - Show Hidden Folders and Files
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d "1" /f

rem 2 - Open File Explorer to Quick access / 1 - Open File Explorer to This PC
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d "2" /f

rem 0 - Do not use Sharing Wizard
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SharingWizardOn" /t REG_DWORD /d "0" /f

rem 1 - Launch folder windows in a separate process
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "SeparateProcess" /t REG_DWORD /d "1" /f

rem 1 - Show protected operating System files 
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d "1" /f

rem 0 - Hide Task View button
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f

rem Remove Desktop folder from This PC
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f

rem Remove Documents folder from This PC
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f

rem Remove Downloads folder from This PC
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f

rem Remove Music folder from This PC on
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f

rem Remove Pictures folder from This PC
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f

rem Remove Videos folder from This PC
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f
reg delete "HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f

rem ========================= Windows Logging =========================

rem DiagLog required by Diagnostic Policy Service
rem EventLog-Application required by Windows
rem EventLog-System required by Windows
rem msdn.microsoft.com/en-us/library/windows/desktop/aa363687(v=vs.85).aspx

reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\Audio" /v "Start" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\MpWppTracing-07202016-140038-00000003-ffffffff" /v "Start" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\ReadyBoot" /v "Start" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\SQMLogger" /v "Start" /t REG_DWORD /d "0" /f
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\WiFiSession" /v "Start" /t REG_DWORD /d "0" /f

rem ========================= Windows Network =========================

rem Windows wmic command line command
rem www.computerhope.com/wmic.htm

rem To get adapter's index number use command:
rem wmic nicconfig get caption,index,TcpipNetbiosOptions

rem Disable IPv6
netsh int ipv6 isatap set state disabled
netsh int teredo set state disabled
netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled
reg add "HKLM\System\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d "255" /f

rem 0 - Disable LMHOSTS Lookup on all adapters / 1 - Enable
reg add "HKLM\System\CurrentControlSet\Services\NetBT\Parameters" /v "EnableLMHOSTS" /t REG_DWORD /d "0" /f

rem 2 - Disable NetBIOS over TCP/IP on all adapters / 1 - Enable / 0 - Default
wmic nicconfig where TcpipNetbiosOptions=0 call SetTcpipNetbios 2
wmic nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2

rem Setup DNS Servers on DHCP Enabled Network  https://blog.adguard.com/en/adguard-dns-beta
wmic nicconfig where DHCPEnabled=TRUE call SetDNSServerSearchOrder ("176.103.130.131","176.103.130.130")

rem Setup IP, Gateway and DNS Servers based on the MAC address (To Enable DHCP: wmic nicconfig where macaddress="28:E3:47:18:70:3D" call enabledhcp)
wmic nicconfig where macaddress="68:F7:28:0F:B6:D5" call EnableStatic ("10.10.10.20"), ("255.255.255.0")
wmic nicconfig where macaddress="68:F7:28:0F:B6:D5" call SetDNSServerSearchOrder ("176.103.130.131","176.103.130.130")
wmic nicconfig where macaddress="68:F7:28:0F:B6:D5" call SetGateways ("10.10.10.10")

rem Disable Windows Firewall / AllProfiles / CurrentProfile / DomainProfile / PrivateProfile / PublicProfile
rem technet.microsoft.com/en-us/library/cc771920(v=ws.10).aspx
netsh advfirewall set allprofiles state off

rem ========================= Windows Notifications =========================

rem 1 - Show me tips about Windows / Can cause high disc usage via a process System and compressed memory
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /t REG_DWORD /d "0" /f

rem 0 - Turn on Quiet Hours in Action Center / Disable/Hide the message: Turn on Windows Security Center service
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_TOASTS_ENABLED" /t REG_DWORD /d "0" /f

rem Do not show app Notifications
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoToastApplicationNotification" /t REG_DWORD /d "1" /f

rem 1 - Do not show alarms, reminders and incoming VOIP calls on the lock
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f

rem 1 - Do not show notifications on the lock screen
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /t REG_DWORD /d "0" /f

rem 1 - Hide notifications while presenting
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_SUPRESS_TOASTS_WHILE_DUPLICATING" /t REG_DWORD /d "0" /f

rem 1808 - Disable the warning The Publisher could not be verified
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "DefaultFileTypeRisk" /t REG_DWORD /d "1808" /f

rem Disable Security warning to unblock the downloaded file
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d "1" /f

rem 1 - Display confirmation dialog when deleting files
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ConfirmFileDelete" /t REG_DWORD /d "1" /f

rem ========================= Windows Optimizations =========================

rem blogs.technet.microsoft.com/markrussinovich/2008/07/21/pushing-the-limits-of-windows-physical-memory
rem channel9.msdn.com/Blogs/Seth-Juarez/Memory-Compression-in-Windows-10-RTM

rem Determines whether user processes end automatically when the user either logs off or shuts down / 1 - Processes end automatically
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f

rem When the time is set too low, apps like Settings will crash, system icons like Volume and Power will disappear
rem www.tenforums.com/drivers-hardware/21217-volume-icon-not-appearing-taskbar.html#post578321
rem Specifies in milliseconds how long the System waits for user processes to end after the user clicks the End Task command button in Task Manager
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "5000" /f

rem Determines how long the System waits for user processes to end after the user attempts to log off or to shut down
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "10000" /f

rem Determines in milliseconds how long the System waits for services to stop after notifying the service that the System is shutting down
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "10000" /f

rem Determines in milliseconds the interval from the time the cursor is pointed at a menu until the menu items are displayed
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f

rem  Mouse Hover Time in milliseconds before Pop-up Display
reg add "HKCU\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "0" /f

rem How long in milliseconds you want to have for a startup delay time for desktop apps that run at startup to load
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v "StartupDelayInMSec" /t REG_DWORD /d "0" /f

rem n - Disable Background disk defragmentation / y - EnableHow long in milliseconds you want to have for a startup delay time for desktop apps that run at startup to load
reg add "HKLM\Software\Microsoft\Dfrg\BootOptimizeFunction" /v "Enable" /t REG_SZ /d "n" /f

rem 0 - Disable Background auto-layout / Disable Optimize Hard Disk when idle
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\OptimalLayout" /v "EnableAutoLayout" /t REG_DWORD /d "0" /f

rem 1 - Disable Automatic Maintenance
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d "1" /f

rem 1 - NTFS does not create short file names
reg add "HKLM\System\CurrentControlSet\Control\FileSystem" /v "NtfsDisable8dot3NameCreation" /t REG_DWORD /d "1" /f

rem 1 - Disable the Encrypting File System (EFS)
reg add "HKLM\System\CurrentControlSet\Control\FileSystem" /v "NtfsDisableEncryption" /t REG_DWORD /d "1" /f

rem 1 - When listing directories, NTFS does not update the last-access timestamp, and it does not record time stamp updates in the NTFS log
reg add "HKLM\System\CurrentControlSet\Control\FileSystem" /v "NtfsDisableLastAccessUpdate" /t REG_DWORD /d "1" /f

rem 0 - Establishes a standard size file-system cache of approximately 8 MB / 1 - Establishes a large system cache working set that can expand to physical memory, minus 4 MB, if needed
rem technet.microsoft.com/en-us/library/cc784562(v=ws.10).aspx
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d "0" /f

rem 0 - Drivers and the kernel can be paged to disk as needed / 1 - Drivers and the kernel must remain in physical memory
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "DisablePagingExecutive" /t REG_DWORD /d "1" /f

rem 0 - Disable Prefetch / 1 - Enable Prefetch when the application starts / 2 - Enable Prefetch when the device starts up / 3 - Enable Prefetch when the application or device starts up
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f

rem 0 - Disable SuperFetch / 1 - Enable SuperFetch when the application starts up / 2 - Enable SuperFetch when the device starts up / 3 - Enable SuperFetch when the application or device starts up
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t REG_DWORD /d "0" /f

rem 0 - Disable It / 1 - Default
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "SfTracingState" /t REG_DWORD /d "0" /f

rem 0 - Disable Fast Startup for a Full Shutdown / 1 - Enable Fast Startup (Hybrid Boot) for a Hybrid Shutdown
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f

rem Disable Hibernation / Disable Fast Startup (Hybrid Boot)
powercfg -h off

rem ========================= Windows Policies =========================

rem 0 - Disable Microsoft Windows Just-In-Time (JIT) script debugging
reg add "HKCU\Software\Microsoft\Windows Script\Settings" /v "JITDebug" /t REG_DWORD /d "0" /f
reg add "HKU\.Default\Microsoft\Windows Script\Settings" /v "JITDebug" /t REG_DWORD /d "0" /f

rem 0 - Disable Windows SmartScreen for Windows Store Apps / 0 - Enable
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t "REG_DWORD" /d "0" /f

rem Disable Active Desktop
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ForceActiveDesktopOn" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoActiveDesktop" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoActiveDesktopChanges" /t REG_DWORD /d "1" /f

rem Off - Disable Windows SmartScreen / On - Enable Windows SmartScreen 
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f

rem 1 - Disable Autoplay for all media and devices / 0 - Enable
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t REG_DWORD /d "1" /f

rem 0 - Elevate without prompting / 1 - Prompt for credentials on the secure desktop / 2 - Prompt for consent on the secure desktop / 3 - Prompt for credentials / 4 - Prompt for consent / 5 (Default) - Prompt for consent for non-Windows binaries
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d "1" /f

rem 0 - Automatically deny elevation requests / 1 - Prompt for credentials on the secure desktop / 3 (Default) - Prompt for credentials
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorUser" /t REG_DWORD /d "1" /f

rem 2 - Default
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "DSCAutomationHostEnabled" /t REG_DWORD /d "2" /f

rem Detect application installations and prompt for elevation / 1 - Enabled (default for home) / 0 - Disabled (default for enterprise)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableInstallerDetection" /t REG_DWORD /d "1" /f

rem Run all administrators in Admin Approval Mode / 0 - Disabled (UAC) / 1 - Enabled (UAC)
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableLUA" /t REG_DWORD /d "1" /f

rem Only elevate UIAccess applications that are installed in secure locations / 0 - Disabled / 1 (Default) - Enabled
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableSecureUIAPaths" /t REG_DWORD /d "1" /f

rem Allow UIAccess applications to prompt for elevation without using the secure desktop / 0 (Default) = Disabled / 1 - Enabled
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableUIADesktopToggle" /t REG_DWORD /d "0" /f

rem 0 - Disabled / 1 - Enabled (Default)
rem technet.microsoft.com/en-us/itpro/windows/keep-secure/deploy-device-guard-enable-virtualization-based-security
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "EnableVirtualization" /t REG_DWORD /d "0" /f

rem Admin Approval Mode for the built-in Administrator account / 0 (Default) - Disabled / 1 - Enabled
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "FilterAdministratorToken" /t REG_DWORD /d "1" /f

rem 0 - Disable Administrative Shares
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "LocalAccountTokenFilterPolicy" /t REG_DWORD /d "0" /f

rem Allow UIAccess applications to prompt for elevation without using the secure desktop / 0 (Default) - Disabled / 1 - Enabled
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d "1" /f

reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit" /v "ProcessCreationIncludeCmdLine_Enabled" /t REG_DWORD /d "1" /f

rem 0 - Disable Windows Script Host (WSH) for the current user 
reg add "HKCU\Software\Microsoft\Windows Script Host\Settings" /v "Enabled" /t REG_DWORD /d "0" /f

rem 0 - Disable Windows Script Host (WSH) for all users (prevents majority of malware from working, especially when removing PowerShell as well, Disable ExecutionPolicy can be easily bypassed)
rem Locky ransomware using VBscript (Visual Basic Script) - blog.avast.com/a-closer-look-at-the-locky-ransomware
reg add "HKLM\Software\Microsoft\Windows Script Host\Settings" /v "Enabled" /t REG_DWORD /d "0" /f

rem No-one will be a member of the built-in group, although it will still be visible in the Object Picker / 1 - all users logging on to a session on the server will be made a member of the TERMINAL SERVER USER group
reg add "HKLM\System\CurrentControlSet\Control\Terminal Server" /v "TSUserEnabled" /t REG_DWORD /d "0" /f

rem 0 - Disable Administrative Shares / 1 - Enable
reg add "HKLM\System\CurrentControlSet\Services\LanmanServer\Parameters" /v "AutoShareWks" /t REG_DWORD /d "0" /f

rem ========================= Windows Privacy =========================

rem Additional disabled privacy features are disabled in sections: Windows Logging / Windows Scheduled Tasks / Windows Services
rem technet.microsoft.com/itpro/windows/manage/manage-connections-from-windows-operating-system-components-to-microsoft-services

rem Disable Cortana
reg add "HKCU\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f
reg add "HKCU\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "AllowCortana" /t REG_DWORD /d "0" /f
reg add "HKCU\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f

rem Feedback Frequency (Windows should ask for my feedback) / 0 - Never / 1 - Automatically
reg add "HKCU\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d "0" /f

rem 0 - Disable WiFi Sense (shares your WiFi network login with other people)
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v "value" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v "value" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\WcmSvc\wifinetworkmanager\config" /v "AutoConnectAllowedOEM" /t REG_DWORD /d "0" /f

rem Diagnostic and usage data / 0 - Never / 1 - Basic / 2 - Enhanced / 3 - Full
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Program-Telemetry" /v "Enabled" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f

rem 0 - Disable Customer Experience Improvement (CEIP/SQM - Software Quality Management)
reg add "HKLM\Software\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d "0" /f

rem 0 - Disable Application Impact Telemetry (AIT)
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d "0" /f

rem 1 - Disable AD customization
reg add "HKLM\Software\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d "1" /f

rem 1 - Disable Steps Recorder (Steps Recorder keeps a record of steps taken by the user, the data includes user actions such as keyboard input and mouse input user interface data and screen shots)
reg add "HKLM\Software\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d "1" /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Application-Experience/Steps-Recorder" /v "Enabled" /t REG_DWORD /d "0" /f

rem 0 - Disable sending files to encrypted drives
reg add "HKLM\Software\Policies\Microsoft\Windows\EnhancedStorageDevices" /v "TCGSecurityActivationDisabled" /t REG_DWORD /d "0" /f

rem 1 - Disable sync files to one drive
reg add "HKLM\Software\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f

rem 2 - Disable sending settings to cloud
reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSync" /t REG_DWORD /d "2" /f

rem 1 - Disable synchronizing files to cloud
reg add "HKLM\Software\Policies\Microsoft\Windows\SettingSync" /v "DisableSettingSyncUserOverride" /t REG_DWORD /d "1" /f

rem ========================= Windows Scheduled Tasks =========================

rem news.softpedia.com/news/windows-10-disk-cleanup-utility-abused-to-bypass-uac-506614.shtml

rem Disable Background Synchronization (permanently, it can not be disabled) 
schtasks /DELETE /TN "Microsoft\Windows\SettingSync\BackgroundUploadTask" /F

schtasks /Change /TN "Adobe Flash Player Updater" /Disable
schtasks /Change /TN "AMD Updater" /Disable
schtasks /Change /TN "CreateExplorerShellUnelevatedTask" /Disable
schtasks /Change /TN "Driver Easy Scheduled Scan" /Disable
schtasks /Change /TN "Update for Yandex Browser" /Disable
schtasks /Change /TN "WpsExternal_Mikai_20160918174359" /Disable
schtasks /Change /TN "WpsKtpcntrQingTask_Mikai" /Disable
schtasks /Change /TN "WpsUpdateTask_Mikai" /Disable
schtasks /Change /TN "Yandex Browser system update" /Disable
schtasks /Change /TN "Yandex Browser update" /Disable

schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTask" /Disable
schtasks /Change /TN "Microsoft\XblGameSave\XblGameSaveTaskLogon" /Disable

schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319" /Disable
schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64" /Disable
schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 64 Critical" /Disable
schtasks /Change /TN "Microsoft\Windows\.NET Framework\.NET Framework NGEN v4.0.30319 Critical" /Disable
schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\CleanupTemporaryState" /Disable
schtasks /Change /TN "Microsoft\Windows\ApplicationData\DsSvcCleanup" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable
schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
schtasks /Change /TN "Microsoft\Windows\Defrag\ScheduledDefrag" /Disable
schtasks /Change /TN "Microsoft\Windows\Diagnosis\Scheduled" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskCleanup\SilentCleanup" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\StorageSense" /Disable
schtasks /Change /TN "Microsoft\Windows\ErrorDetails\EnableErrorDetailsUpdate" /Disable
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClient" /Disable
schtasks /Change /TN "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" /Disable
schtasks /Change /TN "Microsoft\Windows\File Classification Infrastructure\Property Definition Sync" /Disable
schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable
schtasks /Change /TN "Microsoft\Windows\Management\Provisioning\Logon" /Disable
schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Disable
schtasks /Change /TN "Microsoft\Windows\Maps\MapsToastTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Maps\MapsUpdateTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Mobile Broadband Accounts\MNO Metadata Parser" /Disable
schtasks /Change /TN "Microsoft\Windows\Multimedia\SystemSoundsService" /Disable
schtasks /Change /TN "Microsoft\Windows\NlaSvc\WiFiTask" /Disable
schtasks /Change /TN "Microsoft\Windows\NetCfg\BindingWorkItemQueueHandler" /Disable
schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable
schtasks /Change /TN "Microsoft\Windows\Offline Files\Background Synchronization" /Disable
schtasks /Change /TN "Microsoft\Windows\Offline Files\Logon Synchronization" /Disable
schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Disable
schtasks /Change /TN "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem" /Disable
schtasks /Change /TN "Microsoft\Windows\Ras\MobilityManager" /Disable
schtasks /Change /TN "Microsoft\Windows\RemoteAssistance\RemoteAssistanceTask" /Disable
schtasks /Change /TN "Microsoft\Windows\RetailDemo\CleanupOfflineContent" /Disable
schtasks /Change /TN "Microsoft\Windows\Servicing\StartComponentCleanup" /Disable
schtasks /Change /TN "Microsoft\Windows\SettingSync\BackupTask" /Disable
schtasks /Change /TN "Microsoft\Windows\SettingSync\NetworkStateChangeTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Setup\SetupCleanupTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyMonitor" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyRefresh" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\IndexerAutomaticMaintenance" /Disable
schtasks /Change /TN "Microsoft\Windows\SpacePort\SpaceAgentTask" /Disable
schtasks /Change /TN "Microsoft\Windows\SpacePort\SpaceManagerTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Speech\SpeechModelDownloadTask" /Disable
schtasks /Change /TN "Microsoft\Windows\TextServicesFramework\MsCtfMonitor" /Disable
schtasks /Change /TN "Microsoft\Windows\TPM\Tpm-HASCertRetr" /Disable
schtasks /Change /TN "Microsoft\Windows\TPM\Tpm-Maintenance" /Disable
schtasks /Change /TN "Microsoft\Windows\User Profile Service\HiveUploadTask" /Disable
schtasks /Change /TN "Microsoft\Windows\WCM\WiFiTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Filtering Platform\BfeOnServiceStartTypeChange" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Media Sharing\UpdateLibrary" /Disable
schtasks /Change /TN "Microsoft\Windows\Wininet\CacheTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Work Folders\Work Folders Logon Synchronization" /Disable
schtasks /Change /TN "Microsoft\Windows\Work Folders\Work Folders Maintenance Work" /Disable
schtasks /Change /TN "Microsoft\Windows\Workplace Join\Automatic-Device-Join" /Disable

rem ========================= Windows Services =========================

rem postimg.org/image/qfr9pt23z
rem servicedefaults.com/10
rem Security Accounts Manager has to be disabled Manually via services.msc

rem Application Information / required by UAC
rem Background Intelligent Transfer Service / required by Windows Updates / depends on Network List Service
rem Credential Manager / required to store credentials (check User Accounts - Credential Manager)
rem COM+ Event System / required by Windows
rem Connected User Experiences and Telemetry / required by Windows Insider and some Windows Store apps like Weather (enable Location in Privacy Settings, it enables Geolocation service)
rem Delivery Optimization / required by Windows Updates
rem Diagnostic Policy Service / might be required to login to Microsoft Account (to find out, there is a working network) and by Windows Diagnostic (Troubleshooting)
rem DHCP Client / required by Windows Updates
rem Distributed Link Tracking Client / required to open shortcuts and System apps (Windows cannot access the specified device, path, or file. You may not have the appropriate permission to access the item.)
rem Geolocation Service / required by some Windows Store apps, it can not be enabled when Connected User Experiences and Telemetry is disabled
rem Microsoft Account Sign-in Assistant / required to login to Microsoft Account
rem Network Connections / required to manage network connections
rem Network Connection Broker / required to change Network Settings
rem Network List Service / required to change Network Settings
rem Network Store Interface Service / required by Windows Store, Updates and some apps like HitmanPro, without it Windows assumes, there is no internet connection
rem One Drive / required by Windows Mail
rem Print Spooler / required by printers
rem Windows Biometric Service / required by biometric devices like a fingerprint reader
rem Windows Connection Manager / required by WiFi and Data Usage
rem Windows Driver Foundation - User-mode Driver Framework / required by some drivers like USB devices
rem Windows Firewall (Base Filtering Engine) / required by Windows Store Apps (0x80073d0a) and Windows Update (0x80240022)
rem Windows Image Acquisition (WIA) / required by scanners

rem Isolate a service in its own scvhost.exe
rem answers.microsoft.com/en-us/windows/forum/windows_10-networking/november-update-1511-wifi-issue-wifi-keeps/999a92ab-fa69-4f8a-a9dc-27dfa7385a5e?auth=1
sc config storsvc type= own

rem ACP User Service
sc config amdacpusrsvc start= disabled

rem AdaptiveSleepService
sc config AdaptiveSleepService start= disabled

rem Adobe Flash Player Update Service
sc config AdobeFlashPlayerUpdateSvc start= disabled

rem AMD External Events Utility
sc config "AMD External Events Utility" start= disabled

rem Application Layer Gateway Service
sc config ALG start= disabled

rem Background Intelligent Transfer Service / It will change itself to Automatic regularly, disable Network List Service and it will disable BITS as well
rem www.secureworks.com/blog/malware-lingers-with-bits
sc config BITS start= demand

rem Base Filtering Engine
sc config BFE start= disabled

rem BitLocker Drive Encryption Service
sc config BDESVC start= disabled

rem CDPUserSvc
sc config CDPUserSvc start= disabled

rem CNG Key Isolation
sc config KeyIso start= disabled

rem Connected User Experiences and Telemetry
sc config DiagTrack start= disabled

rem Conexant Audio Message Service
sc config CxAudMsg start= disabled

rem Conexant SmartAudio service
sc config SAService start= disabled

rem Contact Data
reg add "HKLM\System\CurrentControlSet\Services\PimIndexMaintenanceSvc" /v "Start" /t REG_DWORD /d "4" /f

rem Credential Manager
sc config VaultSvc start= disabled

rem Delivery Optimization
sc config DoSvc start= demand

rem DHCP Client
sc config Dhcp start= disabled

rem Diagnostic Policy Service
sc config DPS start= disabled

rem Distributed Link Tracking Client
sc config TrkWks start= demand

rem Distributed Transaction Coordinator
sc config MSDTC start= disabled

rem dmwappushsvc
sc config dmwappushservice start= disabled

rem DNS Client (Required by the internet connection, unless you set up DNS servers manually in IPv4/6's properties)
sc config Dnscache start= disabled

rem Encrypting File System (EFS)
sc config EFS start= disabled

rem Function Discovery Provider Host
sc config fdPHost start= disabled

rem Function Discovery Resource Publication
sc config FDResPub start= disabled

rem HomeGroup Provider
sc config HomeGroupProvider start= disabled

rem IKE and AuthIP IPsec Keying Modules
sc config IKEEXT start= disabled

rem IP Helper
sc config iphlpsvc start= disabled

rem IPsec Policy Agent
sc config PolicyAgent start= disabled

rem Network List Service
sc config netprofm start= disabled

rem Network Location Awareness
sc config NlaSvc start= disabled

rem Network Store Interface Service (Required by the internet connection, unless you set up IP/DNS manually in IPv4/6's properties)
sc config nsi start= disabled

rem Offline Files
sc config CscService start= disabled

rem One Drive Service
sc config OneSyncSvc start= disabled

rem Print Spooler
sc config Spooler start= disabled

rem Program Compatibility Assistant Service
sc config PcaSvc start= disabled

rem Remote Desktop Services
sc config TermService start= disabled

rem Retail Demo
sc config RetailDemo start=disabled

rem Secure Socket Tunneling Protocol Service
sc config SstpSvc start= disabled

rem Security Center
sc config wscsvc start= disabled

rem Server
sc config LanmanServer start= disabled

rem Shell Hardware Detection
sc config ShellHWDetection start= disabled

rem Smart Card
sc config SCardSvr start= disabled

rem SSDP Discovery
sc config SSDPSRV start= disabled

rem Superfetch
sc config SysMain start= disabled

rem TCP/IP NetBIOS Helper (Required by some internet connections like aDSL)
sc config lmhosts start= disabled

rem TeamViewer
sc config TeamViewer start= disabled

rem Update service
sc config "Update service" start= disabled

rem User Data Access
reg add "HKLM\System\CurrentControlSet\Services\UserDataSvc" /v "Start" /t REG_DWORD /d "4" /f

rem User Data Storage
reg add "HKLM\System\CurrentControlSet\Services\UnistoreSvc" /v "Start" /t REG_DWORD /d "4" /f

rem WebClient
sc config WebClient start= disabled

rem Windows Biometric Service
sc config WbioSrvc start= disabled

rem Windows Connect Now - Config Registrar (Required by WPS WiFi connection)
sc config wcncsvc start= disabled

rem Windows Connection Manager (Required by WiFi Connection)
sc config Wcmsvc start= disabled

rem Windows Error Reporting Service
sc config WerSvc start= disabled

rem Windows Firewall
sc config MpsSvc start= disabled

rem Windows Font Cache Service
sc config FontCache start= disabled

rem Windows Network Data Usage Monitoring Driver service (Kernel mode driver)
sc config ndu start= disabled

rem Windows Image Acquisition (WIA)
sc config stisvc start= disabled

rem Windows Push Notifications System Service
sc config WpnService start= disabled

rem Windows Remote Management (WS-Management)
sc config WinRM start= disabled

rem Windows Search
sc config WSearch start= disabled

rem Windows Update
sc config wuauserv start= disabled

rem WinHTTP Web Proxy Auto-Discovery Service
sc config WinHttpAutoProxySvc start= disabled

rem Wise Boot Assistant
sc config WiseBootAssistant start= disabled

rem WMPNetworkSVC helps windows media player to share its library with network
sc config WMPNetworkSvc start= disabled

rem Workstation
sc config LanmanWorkstation start= disabled

rem WPS Office Cloud Service
sc config wpscloudsvr start= disabled

rem WPS Office Update Service
sc config Kingsoft_WPS_UpdateService start= disabled

rem Yandex.Browser Update Service
sc config YandexBrowserService start= disabled

rem ========================= Windows Shell =========================

rem www.tenforums.com/tutorials/3123-clsid-key-guid-shortcuts-list-windows-10-a.html

rem Add “Take Ownership” Option in Files and Folders Context Menu in Windows (Disabled, replace rem with reg)
reg add "HKCR\*\shell\runas" /ve /t REG_SZ /d "Take ownership" /f
reg add "HKCR\*\shell\runas" /v "HasLUAShield" /t REG_SZ /d "" /f
reg add "HKCR\*\shell\runas" /v "NoWorkingDirectory" /t REG_SZ /d "" /f
reg add "HKCR\*\shell\runas\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" && icacls \"%%1\" /grant administrators:F" /f
reg add "HKCR\*\shell\runas\command" /v "IsolatedCommand" /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" && icacls \"%%1\" /grant administrators:F" /f
reg add "HKCR\Directory\shell\runas" /ve /t REG_SZ /d "Take ownership" /f
reg add "HKCR\Directory\shell\runas" /v "HasLUAShield" /t REG_SZ /d "" /f
reg add "HKCR\Directory\shell\runas" /v "NoWorkingDirectory" /t REG_SZ /d "" /f
reg add "HKCR\Directory\shell\runas\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" /r /d y && icacls \"%%1\" /grant administrators:F /t" /f
reg add "HKCR\Directory\shell\runas\command" /v "IsolatedCommand" /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\" /r /d y && icacls \"%%1\" /grant administrators:F /t" /f

rem Remove Send To from Context Menu
reg delete "HKCR\AllFilesystemObjects\shellex\ContextMenuHandlers\SendTo" /f

rem ========================= Windows Updates =========================

rem support.microsoft.com/en-us/help/12387/windows-10-update-history
rem technet.microsoft.com/en-us/library/dd939844(v=ws.10).aspx

rem Use Windows Update MiniTool to check/download/install/hide updates
rem forums.mydigitallife.info/threads/64939-Windows-Update-MiniTool

rem Disable Windows Store Automatic App Updates
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" /v "AutoDownload" /t REG_DWORD /d "2" /f

rem 1 = Disable Automatic Updates / Remove - Enable Automatic Updates (Manual checking for updates triggers automatic download of updates and ignores AUOptions)
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t REG_DWORD /d "1" /f

rem Choose how updates are delivered / 0 - Get Updates from MS / 1 - get updates from MS and from/to PCs on my local network / 2 - get updates from MS and from/to PCs on my local network and PCs on the internet
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v "DODownloadMode" /t REG_DWORD /d "0" /f

rem 0 - Default / 1 - Defer upgrades, new Windows features won’t be downloaded or installed for several months. Deferring upgrades doesn’t affect security updates.
reg add "HKLM\Software\Microsoft\WindowsUpdate\UX\Settings" /v "DeferUpgrade" /t REG_DWORD /d "0" /f

rem Active Hours - Windows Updates will not automatically restart your device during active hours
reg add "HKLM\Software\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursEnd" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Microsoft\WindowsUpdate\UX\Settings" /v "ActiveHoursStart" /t REG_DWORD /d "12" /f

rem 1 - Disable Malicious Software Removal Tool offered via Windows Updates (MRT)
reg add "HKLM\Software\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d "1" /f

rem 1 - Disable driver updates in Windows Update (Better to be shown and then hidden than just completely ignored)
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d "1" /f

rem 1 - Restart notification allows user to initiate the restart or postpone restart. This notification does not have a countdown timer. The user must initiate the system restart.
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AlwaysAutoRebootAtScheduledTime" /t REG_DWORD /d "0" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /t REG_DWORD /d "1" /f

sc config wuauserv start= demand
schtasks /DELETE /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /f
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Reboot" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\Refresh Settings" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_Display" /Disable
schtasks /Change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker_ReadyToReboot" /Disable
schtasks /DELETE /TN "Microsoft\Windows\WindowsUpdate\Scheduled Start" /f
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sih" /Disable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\sihboot" /Disable

rem ========================= Windows Waypoint =========================

fsutil usn deletejournal /d /n c:
shutdown /a

rem Close Edge process
taskkill /f /im dllhost.exe

rem Run CCleaner and shutdown
start "" "C:\Program Files\CCleaner\CCleaner64.exe" /AUTO /SHUTDOWN

rem Is that all? Is that ALL? Yes, that is all. That is all.
rem youtu.be/MTjs5eo4BfI?t=1m47s
rem postimg.org/image/jfrhh2wjd