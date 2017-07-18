$GitFolder = "C:\Users\Administrator\AppData\Local\GitHub\PortableGit_f02737a78695063deace08e96d5042710d3e32db\cmd"
$GitUrl = 'ssh://557efa6d5004468c93000167@panasonic-cablocator.rhcloud.com/~/git/panasonic.git/'
$sLocalRepo = "$env:SystemDrive\cablocator"

function fInitialSetup
{
    #Install latest chocolately
    iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

    #Grab latest ruby gems
    $WebClient = New-Object System.Net.WebClient
    $WebClient.DownloadFile("https://rubygems.org/downloads/rubygems-update-2.6.7.gem","C:\rubygems-update-2.6.7.gem")

    #Install ruby and git
    & cinst ruby -version "2.0.0.64800" -confirm
    & cinst git.install

    #Update ruby gems
    $sRuby = (Get-ChildItem -Path "$env:SystemDrive\tools\ruby*\bin").FullName
    & $sRuby\gem install --local C:\rubygems-update-2.6.7.gem
    & $sRuby\update_rubygems --no-ri --no-rdoc

    #Install rhc gems
    & $sRuby\gem install rhc

    #Run rhc setup
    #Answers:
    # default (openshift.redhat.com)
    # brianfgonzalez@gmail.com
    # P@ssw0rd
    # yes (gen token)
    # yes (upload it)
    # default (brianfgonzalezBG)
    & $sRuby\rhc setup

    #Clone the repo
    If ( Test-Path($sLocalRepo) ) { Remove-Item $sLocalRepo -Recurse -Force }
    & "$GitFolder\git.exe" clone "$GitUrl" "$sLocalRepo"
    & explorer.exe "$sLocalRepo"
}

function fPerformSync
{
Param([String]$sCommitTag="Desired Changes")
#Example commands for commiting changes
Set-Location "$sLocalRepo"
& "$GitFolder\git.exe" add --all
& "$GitFolder\git.exe" commit -m "$sCommitTag"
& "$GitFolder\git.exe" push
}

#fInitialSetup
fPerformSync -sCommitTag "Adding WWAN banner."