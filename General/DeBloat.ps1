#############Editable Variables#####################

$Tstamp = Get-Date -format "dd-MMM-yyyy_HH-mm-ss"
$LogPath = "\\server\share\debloat"
$LogFile = "debloat.log"
$Dl_Programs_By_GUID = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/oem/programs_to_target_by_GUID.txt"
$Dl_Programs_By_NAME = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/oem/programs_to_target_by_name.txt"
$Dl_Toolbars_By_GUID = "https://raw.githubusercontent.com/bmrf/tron/master/resources/stage_2_de-bloat/oem/toolbars_BHOs_to_target_by_GUID.txt"


############Phase0 Initialization Do Not Edit Below#######################
$ProgramsRemoved = @()
$Programs = Get-CIMInstance -Classname Win32_Product
$InstalledSoftware = $Programs | Select -Expandproperty "Identifyingnumber"
mkdir $LogPath -ea SilentlyContinue


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
$ProgramsRemoved += $Programs -match $_ | Select Name,IdentifyingNumber
}


###########Phase2 Removal Using WildCard Names#########################

## Search Through The List Of Programs In "Programs_To_Target_Name.Txt" File And Uninstall Them One-By-One
$WebrequestStringArray = ((Iwr $Dl_Programs_By_NAME).Tostring() -Replace "%%","*").Split([Environment]::Newline) | where {$_} 
Foreach ($String In $WebrequestStringArray) { 
  If ($Uninstalling = $Programs | Where {$_.Name -Like $String})
  {
    $Uninstalling | Invoke-Cimmethod -Methodname Uninstall -Whatif  
    $ProgramsRemoved += $Programs -match $uninstalling.IdentifyingNumber | Select Name,IdentifyingNumber
  }
}


###########Phase3 Logging the removed programs#########################
$ProgramsRemoved | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $Env:COMPUTERNAME
$ProgramsRemoved | Add-Member -MemberType NoteProperty -Name "TimeStamp" -Value $Tstamp
$ProgramsRemoved | select Hostname, Timestamp, Name, IdentifyingNumber | Export-Csv -append $LogPath\$LogFile -NoTypeInformation
