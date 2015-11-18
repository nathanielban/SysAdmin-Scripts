# Age the file must be to be deleted minimum of 1 day
$age = 1

# Path to print que folder
$path = "C:\Windows\System32\spool\PRINTERS"

# Function to get date of file
$limit = (Get-Date).AddDays(-$age)

# Stop the Printer Service
Stop-Service spooler

# Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

# Delete any empty directories left behind after deleting the old files.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse

# Start the Printer Service
Start-Service spooler
