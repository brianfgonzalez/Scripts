
Run("notepad.exe")
WinWaitActive("Untitled - Notepad")
Send("This is line 1" & @CRLF)
Send("This is line 2" & @CRLF)
Send("This is line 3" & @CRLF)
Send("This is line 4" & @CRLF)
;WinClose("Untitled - Notepad")
;WinWaitActive("Notepad", "Save")
;WinWaitActive("Notepad", "Do you want to save") ; When running under Windows XP
;Send("!n")