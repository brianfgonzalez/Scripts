echo sel dis 0 >"%~dp0diskpartanswers.txt"
echo clean>>"%~dp0diskpartanswers.txt"
diskpart /s "%~dp0diskpartanswers.txt"