$getWWANCarrier = UniformGrid -ControlName "Get-SelectedWWAN" -Columns 2 {
    New-RadioButton -Name Verizon
    "Verizon"
    New-RadioButton -Name ATT
    "ATT"
    New-RadioButton -Name Spint
    "Sprint"
    New-Button "OK" -On_Click {
        Get-ParentControl |
        Set-UIValue -passThru |
        Close-Control
    }
} -Show