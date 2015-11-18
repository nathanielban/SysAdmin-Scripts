# change age to the amount of days old the file has to be.
$age = 1
# Change path to folder to monitor full path necessary I.E. C:\Windows\System32\spool\PRINTERS
$path = "C:\Windows\System32\spool\PRINTERS"
#Leave Alone
$limit = (Get-Date).AddDays(-$age)

Stop-Service spooler
# Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

# Delete any empty directories left behind after deleting the old files.
Get-ChildItem -Path $path -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
Start-Service spooler