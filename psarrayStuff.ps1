foreach ($path in (Get-ChildItem -Path "C:\" -Directory))
{
    Write-Host $path
}