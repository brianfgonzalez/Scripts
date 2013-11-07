Get-ChildItem -Path C:\HydrationCM2012R2\DS\Scripts\ -Recurse | `
    Where-Object {$_.Extension -eq ".WSF" -or $_.Extension -eq ".VBS"} | `
    foreach{(Get-Content $_.FullName).Count} | Measure-Object -Sum