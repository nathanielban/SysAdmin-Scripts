## By DEFAULT, LOGPATH is the parent directory for all of Tron's output (logs, backups, etc). Tweak the paths below to your liking if you want to change it
$TSTAMP = Get-Date -format "dd-MMM-yyyy_HH-mm-ss"
$LOGPATH = "C:\tron\logs\Logs\tron\"
$LOGFILE = "tron_debloat_%TSTAMP%.log"
$DL_programs_to_target_by_GUID = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_GUID.bat"
$DL_programs_to_target_by_name = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_name.txt"
$DL_toolbars_BHOs_to_target_by = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/toolbars_BHOs_to_target_by_GUID.bat"

## JOB: Remove crapware programs, phase 1: by specific GUID
## Search through the list of programs in "programs_to_target_by_GUID.bat" file and uninstall them one-by-one
Invoke-WebRequest $DL_programs_to_target_by_GUID -OutFile programs_to_target_by_GUID.bat
cmd /k ./programs_to_target_by_GUID.bat >> "%LOGPATH%\%LOGFILE%" 2>&1

## JOB: Remove crapware programs, phase 2: wildcard by name
## Search through the list of programs in "programs_to_target_name.txt" file and uninstall them one-by-one
Invoke-WebRequest $DL_programs_to_target_by_name -OutFile programs_to_target_by_name.txt
$P2TBN = Get-Content programs_to_target_by_name.txt
foreach ($P2TBN in $P2TBN) {
    WMIC product where "name like '$P2TBN'" uninstall /nointeractive -outfile "$LOGPATH\$LOGFILE"
}

## JOB: Remove crapware programs, phase 3: unwanted toolbars and BHOs by GUID
## Search through the list of programs in "toolbars_BHOs_to_target_by_GUID.bat" file and uninstall them one-by-one
Invoke-WebRequest $DL_toolbars_BHOs_to_target_by -OutFile toolbars_BHOs_to_target_by_GUID.bat
cmd /k ./toolbars_BHOs_to_target_by_GUID.bat >> "%LOGPATH%\%LOGFILE%" 2>&1

## test below
##(iwr https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_GUID.bat).ToString().Split([Environment]::Newline) | ? {$_ -match "^start"} | % { sps $_.split()[2..($_.Split().Length)] }
#$webrequest = iwr https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_GUID.bat
#$file = $webrequest.ToString()
#$lines = $file.Split([Environment]::Newline)
#foreach ($line in $lines) {
#   if ($line -match "^start") {
#    Start-Process $line.split()[2..($line.Split().Length)]
#  }
#}