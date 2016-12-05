function prompt
{
    $Sentences = @(
                    "Let's see"
                    "Typing"
                    "Typing, typing"
                    "Typing, typing, busy, busy"
                    "Create a GUI using Visual Basic"
                    "Wait, I'll fix this"
                    "What the"
                    "Hold on a second"
                    "This should be easy"
                    "This was supposed to be easy"
                    "Is it Monday again"
                    "These must be the gates of hell"
                    "I wish I could sudo this"
                    "This wouldn't happen on a Mac"
                    "Well, this *would* happen on a Mac"
                    "I can't believe this"
                    "You awesome"
                    "You... are not so awesome"
                    "This works"
                    "Well, that worked"
                    "Well, that didn't work"
                    "I swear this should have worked"
                    "I swear this worked last time"
                    "This has never worked"
                    "Hm, this has never done this before"
                    "That's it"
                    )
    $Endings = @(".",":","...","!","?","!?","!?!?","#!)(*$#","/s")

    Write-Host
    Write-Host "$ENV:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$ENV:COMPUTERNAME" -NoNewline -ForegroundColor DarkGray

    Write-Host " : " -NoNewline
    Write-Host $($(Get-Location) -replace ($env:USERPROFILE).Replace('\','\\'), "~") -ForegroundColor DarkYellow -NoNewline
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkCyan
    Write-Host " : " -NoNewline

    Write-Host "Running Procs:" $(Get-Process).Count -NoNewline -ForegroundColor DarkMagenta
    Write-Host

    #Write-Host ($(Get-Date -Format HHmm) + '>') -nonewline -foregroundcolor Green
    $FullSentence = $(Get-Random -InputObject $Sentences) + $(Get-Random -InputObject $Endings)
    Write-Host $(Get-Random -InputObject $FullSentence) -NoNewline -ForegroundColor Green
    return " "

}