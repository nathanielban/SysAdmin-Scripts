#############Variables#####################

$TSTAMP = Get-Date -format "dd-MMM-yyyy_HH-mm-ss"
$LOGPATH = "C:\logs\debloat"
$LOGFILE = "debloat_%TSTAMP%.log"
$ProgramsRemoved = @()
$Dl_Programs_By_GUID = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_GUID.bat"
$Dl_Programs_By_NAME = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/programs_to_target_by_name.txt"
$Dl_Toolbars_By_GUID = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/toolbars_BHOs_to_target_by_GUID.bat"
$Programs = Get-CIMInstance -Classname Win32_Product
$InstalledSoftware = $Programs | Select -Expandproperty "Identifyingnumber"



############Phase1 Removal By GUID#######################

## Get List Of Programs GUIDs From Tron 
$Webrequest = IWR "$Dl_Programs_By_GUID"
$File = $Webrequest.Tostring()
$Lines = $File.Split([Environment]::Newline)
$GUIDVOCprogs = $Lines -Replace ".*?({[0-9a-zA-Z\-]+}).*",'$1' -Replace "^[^{].*" | ? {$_}

## Get List Of Toolbars GUIDs From Tron
$Webrequest = IWR $Dl_Toolbars_By_GUID
$File = $Webrequest.Tostring()
$Lines = $File.Split([Environment]::Newline)
$GUIDVOCToolbars = $Lines -Replace ".*?({[0-9a-zA-Z\-]+}).*",'$1' -Replace "^[^{].*" | ? {$_} #Forgot the where (? is synomomous with where and where-object)

## Make A Bad GUID Concated Variable.
$BadGUIDs = $GUIDVOCprogs + $GUIDVOCToolbars | Select -Unique


## Compare List Of Bad GUID Against Whats Installed
$InstalledBadGUIDs = $InstalledSoftware | Compare $BadGUIDs -Excludedifferent -Includeequal| Select -Expandproperty Inputobject
$InstalledBadGUIDs | Foreach {
Start-Process "Msiexec.Exe" -Argumentlist "/Qn","/Norestart","/X","$_" -Wait
$ProgramsRemoved += $Programs -match $_ | Select -ExpandProperty Name
}


###########Phase2 Removal Using WildCard Names#########################

## Job: Remove Crapware Programs, Phase 2: Wildcard By Name
## Search Through The List Of Programs In "Programs_To_Target_Name.Txt" File And Uninstall Them One-By-One
$Webrequest = ((Iwr $Dl_Programs_By_NAME).Tostring() -Replace "%%","*").Split([Environment]::Newline) | where {$_} #Like Above, This Clears Out Empty Lines. Like At The End Of A File :)
Foreach ($Item In $Webrequest) { 
  If ($Uninstalling = $Programs | Where {$_.Name -Like $Item})
  {
    $Uninstalling | Invoke-Cimmethod -Methodname Uninstall -Whatif  #Send All Programs Through Pipe. Find All Objects That Have A Name Property That Matches One Of The $Item In $Webrequest And Uninstall It
    $ProgramsRemoved += $Programs -match $uninstalling.IdentifyingNumber | Select -ExpandProperty Name #Hmmm, can I match on this object? Might be able to!
  }
}


###########Phase3 Logging the removed programs#########################
$ProgramsRemoved | Out-File $LogPath\$LogFile
