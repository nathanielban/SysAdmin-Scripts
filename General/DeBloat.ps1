## By DEFAULT, LOGPATH is the parent directory for all of Tron's output (logs, backups, etc). Tweak the paths below to your liking if you want to change it
$LOGPATH=%SystemDrive%\Logs\tron\
$LOGFILE=tron_debloat_%TSTAMP%.log
$DRY_RUN=no
$TSTAMP=Get-Date -format "dd-MMM-yyyy_HH-mm-ss"

## JOB: Remove crapware programs, phase 1: by specific GUID
if /i %DRY_RUN%==no Invoke-WebRequest https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_GUID.bat
if /i %DRY_RUN%==no call programs_to_target_by_GUID.bat >> "%LOGPATH%\%LOGFILE%" 2>&1

## JOB: Remove crapware programs, phase 3: unwanted toolbars and BHOs by GUID
if /i %DRY_RUN%==no Invoke-WebRequest https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/toolbars_BHOs_to_target_by_GUID.bat
if /i %DRY_RUN%==no call toolbars_BHOs_to_target_by_GUID.bat >> "%LOGPATH%\%LOGFILE%" 2>&1

:: JOB: Remove crapware programs, phase 2: wildcard by name
title TRON v%SCRIPT_VERSION% [stage_2_de-bloat] [Remove bloatware by name]
call :log "%CUR_DATE% %TIME%    Attempt junkware removal: Phase 2 (wildcard by name)..."
call :log "%CUR_DATE% %TIME%    Customize here: \resources\stage_2_de-bloat\programs_to_target_by_name.txt"
:: Search through the list of programs in "programs_to_target.txt" file and uninstall them one-by-one
if /i %DRY_RUN%==no Invoke-WebRequest https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_name.txt
if /i %DRY_RUN%==no FOR /F "tokens=*" %%i in (programs_to_target_by_name.txt) DO echo   %%i && echo   %%i...>> "%LOGPATH%\%LOGFILE%" && %WMIC% product where "name like '%%i'" uninstall /nointeractive>> "%LOGPATH%\%LOGFILE%"
