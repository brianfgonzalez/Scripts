@echo off

chkdev2.exe /getdevice 801A 0000
echo %errorlevel%

chkdev2.exe /getdevice 8018 0000
echo %errorlevel%

chkdev2.exe /getdevice 8009 0000
echo %errorlevel%

chkdev2.exe /getdevice 8019 0000
echo %errorlevel%

chkdev2.exe /getdevice 801D 0000
echo %errorlevel%

chkdev2.exe /getdevice 8013 0000
echo %errorlevel%

chkdev2.exe /getdevice 8011 0000
echo %errorlevel%

chkdev2.exe /getdevice 800E 0000
echo %errorlevel%

chkdev2.exe /getdevice 8012 0000
echo %errorlevel%

chkdev2.exe /getdevice 8021 0000
echo %errorlevel%

chkdev2.exe /getdevice 8008 83D8
echo %errorlevel%

PAUSE
