pingTest "localhost" 127.0.0.1

Function pingTest ($systemname, $ipaddress)
{
    $retping = test-connection -ComputerName $systemname -Count 1
    Write-Host $systemname " ping result equals: " $retping
}