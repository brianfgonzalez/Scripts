#Check for internet connection
If (-NOT ([Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]'{DCB00C01-570F-4A9B-8D69-199FDBA5723B}')).IsConnectedToInternet))
{
    Write-Warning "Script requires a connection to the internet!"
    Break
}
#Check for admin rights
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] “Administrator”))
{
    Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
    Break
}

$sCabsXmlPath = ('{0}\Desktop\cabs.xml' -f $env:USERPROFILE)
$sOcbsXmlPath = ('{0}\Desktop\ocbs.xml' -f $env:USERPROFILE)

#Populate ocb ftp array
$oFtpReq = [System.Net.FtpWebRequest]::Create("ftp://ftp.panasonic.com/computer/software")
$oFtpReq.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
$oFtpResp = $oFtpReq.GetResponse()
$oFtpResp.GetResponseStream() | Out-Null
$oStreamResp = $oFtpResp.GetResponseStream()
$oStreamReader = New-Object System.IO.Streamreader $oStreamResp

#Clean up ftp cab array
$aFtpOcbList = (($oStreamReader.ReadToEnd()) -split [Environment]::NewLine)
$aFtpOcbList = $aFtpOcbList[2..($aFtpOcbList.Length-2)]

$oStreamReader.Close()
$oFtpResp.Close()

#Populate cab ftp array
$oFtpReq = [System.Net.FtpWebRequest]::Create("ftp://ftp.panasonic.com/computer/cab") 
$oFtpReq.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
$oFtpResp = $oFtpReq.GetResponse()
$oFtpResp.GetResponseStream() | Out-Null
$oStreamResp = $oFtpResp.GetResponseStream()
$oStreamReader = New-Object System.IO.Streamreader $oStreamResp

#Clean up ftp cab array
$aFtpCabList = (($oStreamReader.ReadToEnd()) -split [Environment]::NewLine)
$aFtpCabList = $aFtpCabList[2..($aFtpCabList.Length-2)]

$oStreamReader.Close()
$oFtpResp.Close()

#Now to grab the CAB and OCB information from Google's API
#https://console.developers.google.com/projectselector/apis/credentials
$sClientId = "427543606402-admqlks2g71rmsgu9bnvu0h83t0d1qt6.apps.googleusercontent.com"
$sClientSecret = "aAhBNxtkaO45M_WcSyBM_17C"
$sRedirectUri = "urn:ietf:wg:oauth:2.0:oob"

##If no refresh token - requires human interaction with IE
if(!($sRefreshToken)){
 
    $sScope = "https://www.googleapis.com/auth/drive.readonly"
    $sResponseType = "code"
    $sApprovalPrompt = "force"
    $sAccessType = "offline"
 
    #Build the auth uri for ie call
    $sAuthUri = `
    ('https://accounts.google.com/o/oauth2/auth?scope={0}&response_type={1}&redirect_uri={2}&client_id={3}&access_type={4}&approval_prompt={5}' `
    -f $sScope,$sResponseType,$sRedirectUri,$sClientId,$sAccessType,$sApprovalPrompt)

    #Call ie with auth uri
    $oIe = New-Object -comObject InternetExplorer.Application
    $oIe.visible = $true
    $oIe.navigate($sAuthUri)
    $oIeProcess = Get-Process | ? { $_.MainWindowHandle -eq $oIe.HWND }
    Add-Type -Assembly "Microsoft.VisualBasic"
    [Microsoft.VisualBasic.Interaction]::AppActivate($oIeProcess.Id)

    #Wait for user approval and key capture
    do{Start-Sleep 1}until($oIe.LocationName -match 'code=([$0-9/].*)')
    $sAuthCode = $matches[1]
    $oIe.Quit()

    #Give ie a second to close
    Start-Sleep 1

    #Exchange the authorization code for a refresh token and access token
    $sGrantType = "authorization_code"
    $sRequestUri = "https://accounts.google.com/o/oauth2/token"
    $sRequestBody = `
    ('code={0}&client_id={1}&client_secret={2}&grant_type={3}&redirect_uri={4}' `
    -f $sAuthCode,$sClientId,$sClientSecret,$sGrantType,$sRedirectUri)
 
    $oResponse = Invoke-RestMethod -Method Post -Uri $sRequestUri -ContentType "application/x-www-form-urlencoded" -Body $sRequestBody
    $sRefreshToken = $oResponse.refresh_token
    $sAccessToken = $oResponse.access_token
} else {

    #Exchange the refresh token for an access token
    $sGrantType = "refresh_token"
    $sRequestUri = "https://accounts.google.com/o/oauth2/token"
    $sRequestBody = `
    ('refresh_token={0}&client_id={1}&client_secret={2}&grant_type={3}' `
    -f $sRefreshToken,$sClientId,$sClientSecret,$sGrantType)
    $oResponse = Invoke-RestMethod -Method Post -Uri $sRequestUri -ContentType "application/x-www-form-urlencoded" -Body $sRequestBody
    $sAccessToken = $oResponse.access_token
    $sIdToken = $oResponse.id_token
}

#-------------------CABS----------------------------
#Run query for Cabs first
#---------------------------------------------------
$t = 'https://www.googleapis.com/drive/v3/files?'
#Build query uri pre-encoded, i used "https://developers.google.com/apis-explorer/#p/drive/v3/drive.files.list" to build query string
$y = 'corpus=user&pageSize=1000&q=fileExtension%3D%22cab%22&'+`
    'spaces=drive&fields=files(fileExtension%2Cid%2Cname%2Csize%2Cmd5Checksum%2CcreatedTime%2Cparents)%2CnextPageToken'
$oCabResults = (Invoke-RestMethod ('{0}{1}' -f $t,$y) -Headers @{"Authorization" = "Bearer $sAccessToken"})
$oCabFiles = $oCabResults.files
$sMore = $oCabResults.nextPageToken
while($sMore -ne $null)
{
    $oCabResults = (Invoke-RestMethod ('{0}pageToken%3D{1}&{2}' -f $t,$sMore,$y) -Headers @{"Authorization" = "Bearer $sAccessToken"})
    $oCabFiles += $oCabResults.files
    if ($oCabResults.nextPageToken -eq $sMore) { $sMore = $null }
}


# Create cabs xml file
[xml]$oXml = '<?xml version="1.0"?><cabs></cabs>'
$oCabFiles | Sort-Object id -Unique | ? { $_.name -imatch "\d{1,2}.*MK.*\.cab" } | `
% {
    Write-Host "Processing ----------------$($_.name)----------------"
    $oCabRoot = $oXml["cabs"].AppendChild($oXml.CreateElement('cab'))
    $oCabRoot.SetAttribute("name",$_.name)

    $oCabGoogleLink = $oCabRoot.AppendChild($oXml.CreateElement('googlelink'))
    $oCabGoogleLink.AppendChild($oXml.CreateCDataSection('https://drive.google.com/open?id={0}' -f $_.id))
    #make sure file exist on pana ftp before adding it to xml
    If ($aFtpCabList.Contains($_.name))
    {
      $oCabFtpLink = $oCabRoot.AppendChild($oXml.CreateElement('ftplink'))
      $oCabFtpLink.AppendChild($oXml.CreateCDataSection('ftp://ftp.panasonic.com/computer/software/{0}' -f $_.name))
    }

    #pull model from name
    $Matches = $null
    $oCabModel = $oCabRoot.AppendChild($oXml.CreateElement('model'))
    ('{0}' -f $_.name) -imatch "PDP_(([a-z\-0-9]*)MK([0-9]))"
    if ($Matches -eq $null)
    {
        ('{0}' -f $_.name) -imatch "(..)[a-z0-9]*_(MK[0-9]*)"
        $oCabModel.InnerXml = (('{0}{1}' -f $matches[1],$matches[2]) -ireplace "(FZ|CF|\-)","" -ireplace "MK","mk")
    } else {
        # Section built to support new naming convention '54GHJ_Mk3_Win10x64_1511_1607_V1.00.cab'
        $oCabModel.InnerXml = (('{0}' -f $matches[1]) -ireplace "(FZ|CF|\-)","" -ireplace "MK","mk")
    }

    #pull os from name
    $oCabOs = $oCabRoot.AppendChild($oXml.CreateElement('os'))
    ('{0}' -f $_.name) -imatch "_Win([a-z\.0-9]*)_"
    $oCabOs.InnerXml = ( ('{0}' -f $matches[1]) -ireplace 'X','x' )

    $oCabOs = $oCabRoot.AppendChild($oXml.CreateElement('md5'))
    $oCabOs.InnerXml = $_.md5Checksum
    $oCabOs = $oCabRoot.AppendChild($oXml.CreateElement('parents'))
    $oCabOs.InnerXml = $_.parents
    $oCabOs = $oCabRoot.AppendChild($oXml.CreateElement('size'))
    $oCabOs.InnerXml = $_.size
    $oCabOs = $oCabRoot.AppendChild($oXml.CreateElement('date'))
    $oCabOs.InnerXml = (('{0}' -f $_.createdTime) -split "T")[0]
}
$sorted = $oXml.cabs.cab | sort name -desc
$lastChild = $sorted[-1]
$sorted[0..($sorted.Length-2)] | Foreach {$oXml.cabs.InsertBefore($_,$lastChild)}
$oXml.save($sCabsXmlPath)

#-------------------OCBS----------------------------
#Run query to pull ocbs
#---------------------------------------------------
$t = 'https://www.googleapis.com/drive/v3/files?'
#Build uri pre-encoded, i used "https://developers.google.com/apis-explorer/#p/drive/v3/drive.files.list" to build query string
$y = 'corpus=user&pageSize=1000&q=fileExtension%3D%22exe%22&'+`
    'spaces=drive&fields=files(fileExtension%2Cid%2Cname%2Csize%2Cmd5Checksum%2CcreatedTime%2Cparents)%2CnextPageToken'
$oOcbResults = (Invoke-RestMethod ('{0}{1}' -f $t,$y) -Headers @{"Authorization" = "Bearer $sAccessToken"})
$oOcbFiles = $oOcbResults.files
$sMore = $oOcbResults.nextPageToken
while($sMore -ne $null)
{
    $oOcbResults = (Invoke-RestMethod ('{0}pageToken%3D{1}&{2}' -f $t,$sMore,$y) -Headers @{"Authorization" = "Bearer $sAccessToken"})
    $aOcbFiles += $oOcbResults.files
    if ($oOcbResults.nextPageToken -eq $sMore) { $sMore = $null }
}

# Create ocb xml file
[xml]$oXml = '<?xml version="1.0"?><ocbs></ocbs>'
$oOcbFiles | Sort-Object id -Unique | `
? { $_.name -imatch '\d{1,2}.*MK.*\.exe' } | `
% {
    $oOcbRoot = $oXml["ocbs"].AppendChild($oXml.CreateElement('ocb'))
    $oOcbRoot.SetAttribute("name",$_.name)

    $oOcbGoogleLink = $oOcbRoot.AppendChild($oXml.CreateElement('googlelink'))
    $oOcbGoogleLink.AppendChild($oXml.CreateCDataSection('https://drive.google.com/open?id={0}' -f $_.id))
    #make sure file exist on pana ftp before adding it to xml
    If ($aFtpOcbList.Contains($_.name))
    {
      $oOcbFtpLink = $oOcbRoot.AppendChild($oXml.CreateElement('ftplink'))
      $oOcbFtpLink.AppendChild($oXml.CreateCDataSection('ftp://ftp.panasonic.com/computer/software/{0}' -f $_.name))
    }

    #pull model and os from name
    $Matches = $null
    $oOcbModel = $oOcbRoot.AppendChild($oXml.CreateElement('model'))
    if ($($_.name) -imatch "(..)[a-z0-9]*-(MK[0-9a-z\.]*)-([a-z0-9]*).*\.exe")
    {
        # > 2017 naming convention standard processing
        $oOcbModel.InnerXml = (('{0}{1}' -f $matches[1],$matches[2]) -ireplace "(FZ|CF|\-)","" -ireplace "MK","mk")
    } elseif ($($_.name) -imatch "(..)([a-z0-9]*)-([a-z0-9]*).*\.exe") {
        # Section built to support when no MK level is included 'MX4E-7X64-MK1.exe'
        $oOcbModel.InnerXml = (('{0}' -f $matches[1]) -ireplace "(FZ|CF|\-)","" -ireplace "MK","mk")
    } else {
        # Section built to support new naming convention '54GHJ_Mk3_Win10x64_1511_1607_V1.00.exe'
        ('{0}' -f $_.name) -imatch "(..)[a-z0-9]*_(MK[a-z0-9\.]*)_([a-z0-9]*)"
        $oOcbModel.InnerXml = (('{0}' -f $matches[1]) -ireplace "(FZ|CF|\-)","" -ireplace "MK","mk")
    }

    $oOcbOs = $oOcbRoot.AppendChild($oXml.CreateElement('os'))
    $oOcbOs.InnerXml = ( ('{0}' -f $matches[3]) -ireplace 'X','x' -ireplace '\.','' ).ToUpper()

    $oOcbOs = $oOcbRoot.AppendChild($oXml.CreateElement('md5'))
    $oOcbOs.InnerXml = $_.md5Checksum
    $oOcbOs = $oOcbRoot.AppendChild($oXml.CreateElement('parents'))
    $oOcbOs.InnerXml = $_.parents
    $oOcbOs = $oOcbRoot.AppendChild($oXml.CreateElement('size'))
    $oOcbOs.InnerXml = $_.size
    $oOcbOs = $oOcbRoot.AppendChild($oXml.CreateElement('date'))
    $oOcbOs.InnerXml = (('{0}' -f $_.createdTime) -split "T")[0]
}
$sorted = $oXml.ocbs.ocb | sort name -desc
$lastChild = $sorted[-1]
$sorted[0..($sorted.Length-2)] | Foreach {$oXml.ocbs.InsertBefore($_,$lastChild)}
$oXml.save($sOcbsXmlPath)

#Build csv file displaying what files are missing on our Ftp
[xml]$oXml = Get-Content -Path $sCabsXmlPath
$oXml.cabs.ChildNodes | % { if (-not ([bool]($_.PSobject.Properties.name -match "ftplink"))) { $_ } } | `
% { Add-Member -InputObject $_ -NotePropertyName 'gdriveurl' -NotePropertyValue $_.googlelink.'#cdata-section'; $_ } | `
sort date -Descending | select name,gdriveurl,date,size | Export-Csv -Path "$env:USERPROFILE\Desktop\MissingOnFtp.csv" -NoTypeInformation

[xml]$oXml = Get-Content -Path $sOcbsXmlPath
$oXml.ocbs.ChildNodes | % { if (-not ([bool]($_.PSobject.Properties.name -match "ftplink"))) { $_ } } | `
% { Add-Member -InputObject $_ -NotePropertyName 'gdriveurl' -NotePropertyValue $_.googlelink.'#cdata-section'; $_ } | `
sort date -Descending | select name,gdriveurl,date,size | Export-Csv -Path "$env:USERPROFILE\Desktop\MissingOnFtp.csv" -Append -NoTypeInformation

$oOcbFiles = $null
$oCabFiles = $null