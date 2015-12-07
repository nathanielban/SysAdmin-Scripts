#############Editable Variables#####################

$Tstamp = Get-Date -format "dd-MMM-yyyy_HH-mm-ss"
$LogPath = "C:\downloads"
$LogFile = "debloat.log"
$Dl_Programs_By_GUID = "programs_to_target_by_GUID.bat"
$Dl_Programs_By_NAME = "programs_to_target_by_name.txt"
$Dl_Toolbars_By_GUID = "toolbars_BHOs_to_target_by_GUID.bat"


############Phase0 Initialization Do Not Edit Below#######################
$ProgramsRemoved = @()
$Programs = Get-CIMInstance -Classname Win32_Product
$InstalledSoftware = $Programs | Select -Expandproperty "Identifyingnumber"
mkdir $LogPath -ea SilentlyContinue


############Phase1 Removal By GUID#######################

## Get List Of Programs GUIDs From Tron 
$Lines = Get-Content $Dl_Programs_By_GUID
$GUIDVOCprogs = $Lines -Replace ".*?({[0-9a-zA-Z\-]+}).*",'$1' -Replace "^[^{].*" | ? {$_}

## Get List Of Toolbars GUIDs From Tron
$Lines = Get-Content $Dl_Toolbars_By_GUID
$GUIDVOCToolbars = $Lines -Replace ".*?({[0-9a-zA-Z\-]+}).*",'$1' -Replace "^[^{].*" | ? {$_}

## Make A Bad GUID Concated Variable.
$BadGUIDs = $GUIDVOCprogs + $GUIDVOCToolbars | Select -Unique


## Compare List Of Bad GUID Against Whats Installed
$InstalledBadGUIDs = $InstalledSoftware | Compare $BadGUIDs -Excludedifferent -Includeequal| Select -Expandproperty Inputobject
$InstalledBadGUIDs | Foreach {
$ProgramsRemoved += $Programs -match $_ | Select Name,IdentifyingNumber
}


###########Phase2 Removal Using WildCard Names#########################

## Search Through The List Of Programs In "Programs_To_Target_Name.Txt" File And Uninstall Them One-By-One
$ProgramsByName = (Get-Content $Dl_Programs_By_NAME) -Replace "%%","*"
Foreach ($ProgramName In $ProgramsByName) { 
  If ($Uninstalling = $Programs | Where {$_.Name -Like $ProgramName})
  {
    $ProgramsRemoved += $Programs -match $uninstalling.IdentifyingNumber | Select Name,IdentifyingNumber
  }
}


###########Phase3 Logging the removed programs#########################
$ProgramsRemoved | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $Env:COMPUTERNAME
$ProgramsRemoved | Add-Member -MemberType NoteProperty -Name "TimeStamp" -Value $Tstamp
$ProgramsRemoved | select Hostname, Timestamp, Name, IdentifyingNumber | Export-Csv -append $LogPath\$LogFile -NoTypeInformation
