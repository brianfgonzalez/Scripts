#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=ShowImage.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>


;MsgBox(0, "", @ScriptDir)
; Create ProgressBar GUI
$PicturePath = @ScriptDir & "\logo.bmp"
$oGUI = GUICreate("Panasonic Driver Installer", 600, 130, 0, 0) ;width, height, top, left
$oCompleteProgressLabel = GUICtrlCreateLabel("Complete Process:", 5, 10, 100, 20) ;left, top, width, height
$oCompleteProgressBar = GUICtrlCreateProgress(100, 5, 490, 20, $PBS_SMOOTH)
$oCompletePercentLabel = GUICtrlCreateLabel("", 100, 30, 100, 20)
$oCompleteProgressText = GUICtrlCreateLabel("", 200, 30, 385, 20, $SS_RIGHT)
$oStepProgressLabel = GUICtrlCreateLabel("Current Step:", 5, 65, 100, 20)
$oStepProgressBar = GUICtrlCreateProgress(100, 60, 490, 20, $PBS_SMOOTH)
$oStepPercentLabel = GUICtrlCreateLabel("", 100, 85, 100, 20)
$oStepProgressText = GUICtrlCreateLabel("", 200, 85, 385, 20, $SS_RIGHT)
SplashImageOn("", $PicturePath, 100, 20, 0, 0, 1)

GUISetState(@SW_SHOW)
Sleep(5000)