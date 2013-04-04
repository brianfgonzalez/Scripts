# Author Steven Wong, VNSNY

# if current ps session not as admin, start a ps admin session and run everything below
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"

Start-Process powershell -Verb runAs -ArgumentList $arguments
Break

}

# join computer to vnsny domain with vendorimage account, inject into DirectAccess OU, restart computer
$user = "vnsny\vendor" 
$pass = ConvertTo-SecureString "password" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass 
Add-Computer -credential $DomainCred -DomainName "vnsny.org" -OUPath "OU=Vendor,OU=Workstations,DC=VNSNY,DC=ORG" -PassThru -Restart
