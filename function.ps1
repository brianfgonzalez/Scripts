[CmdletBinding()]
PARAM (
    [Parameter(Mandatory)]
    [string[]]
    $ComputerName
)

Process {
    $ComputerName | Do-Something
}

Begin {
    function Do-Something{
        [CmdletBinding()]
        PARAM (
            [Parameter(ValueFromPipeline)]
            [string]
            $ComputerName
        )

        Begin {
            Write-Host "Start Do-Something"
        }

        Process {
            Write-Host $ComputerName
        }

        End{
            Write-Host "Finished Do-Something"
        }
    }
}