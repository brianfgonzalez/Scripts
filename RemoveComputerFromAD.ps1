$sComputerName = "TEST001"
$ComputersOU = [ADSI] 'LDAP://ou=Workstations,ou=ViaMonstra,dc=corp, dc=ViaMonstra, dc=com'
$sReturn = $ComputersOU.Delete('Computer','CN='+ $sComputerName)