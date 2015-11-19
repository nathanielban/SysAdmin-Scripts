## By DEFAULT, LOGPATH is the parent directory for all of Tron's output (logs, backups, etc). Tweak the paths below to your liking if you want to change it
$TSTAMP = Get-Date -format "dd-MMM-yyyy_HH-mm-ss"
$LOGPATH = "C:\tron\logs\Logs\tron\"
$LOGFILE = "tron_debloat_%TSTAMP%.log"
$DL_programs_to_target_by_GUID = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_GUID.bat"
$DL_programs_to_target_by_name = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_name.txt"
$DL_toolbars_BHOs_to_target_by = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/toolbars_BHOs_to_target_by_GUID.bat"
$InstalledSoftware = Get-Wmiobject -Class win32_product | Select -ExpandProperty "IdentifyingNumber"

## JOB: Remove crapware programs, phase 1: by specific GUID
## Search through the list of programs in "programs_to_target_by_GUID.bat" file and uninstall them one-by-one
$webrequest = iwr $DL_programs_to_target_by_GUID
$file = $webrequest.ToString()
$lines = $file.Split([Environment]::Newline)
$GUIDVOCPROGS = $lines -replace ".*?({[0-9a-zA-Z\-]+}).*",'$1' -replace "^[^{].*" | ? {$_}
##foreach ($line in $lines) {
##   if ($line -match "^start") {
##    Start-Process "msiexec.exe" -argumentlist $line.split()[4..($line.Split().Length)] -wait
##  }
##}
echo $GUIDVOCPROGS
##
## JOB: Remove crapware programs, phase 2: wildcard by name
## Search through the list of programs in "programs_to_target_name.txt" file and uninstall them one-by-one
## $list2 = (iwr $DL_programs_to_target_by_name).tostring().split([Environment]::Newline)
## Foreach ($item in $list2) { 
##    Get-CimInstance -ClassName win32_product -Filter ("name like '" + $item + "'") | Invoke-CIMMethod -MethodName uninstall -whatif
## }

## JOB: Remove crapware programs, phase 3: unwanted toolbars and BHOs by GUID
## Search through the list of programs in "toolbars_BHOs_to_target_by_GUID.bat" file and uninstall them one-by-one
$webrequest = iwr $DL_toolbars_BHOs_to_target_by
$file = $webrequest.ToString()
$lines = $file.Split([Environment]::Newline)
$GUIDVOCTOOLBARS = $lines -replace ".*?({[0-9a-zA-Z\-]+}).*",'$1' -replace "^[^{].*" | ? {$_}
## foreach ($line in $lines) {
##   if ($line -match "^start") {
##    Start-Process "msiexec.exe" -argumentlist $line.split()[4..($line.Split().Length)] -wait
##  }
## }