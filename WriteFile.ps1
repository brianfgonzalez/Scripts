'select disk 0
clean
create partition primary size=500
select partition 1
active
format fs=ntfs label="System" quick
create partition primary size=25000
select partition 2
format fs=ntfs label="Recovery" quick
assign letter = R
create partition primary
select partition 3
format fs=ntfs label="OS" quick
assign letter = C
exit' | Out-File "$env:temp\configHD.txt"

'select disk 0
select volume 1
set ID=27
exit' | Out-File "$env:temp\configHD2.txt"