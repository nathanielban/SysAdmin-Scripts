﻿#===========================================================================================
# AUTHOR:		Unknown 
# DATE:			6/07/2015
# VERSION:		1.0
# COMMENT:		GUI Interface to run Export-MailBox
#				Exchange cmdlet to export a mailbox to a PST file.
#===========================================================================================

$errorActionPreference = "SilentlyContinue"
$scriptRoot = Split-Path (Resolve-Path $myInvocation.MyCommand.Path)
$configIni = Join-Path $scriptRoot MailArchiveConfig.ini -Resolve
#$errorActionPreference = "Continue"
#Check if Exchange PSSnapin is alread loaded. Add it if not already loaded.
$arrPSSnapins = Get-PSSnapin

$bExchangeSnapinLoaded = $false

foreach ($PSSnapin in $arrPSSnapins)
{
	if ($PSSnapin.Name -match "Microsoft.Exchange")
	{
		$bExchangeSnapinLoaded = $true
	}
}

if ($bExchangeSnapinLoaded -eq $false)
{ Add-PSSnapin Microsoft.Exchange*}

[Int]$Threads = 8

#Set the default BadItemLimit count
[Int]$BadItemLimit = 500

#BadItemLimit can be overwritten from the config ini file
Get-Content $configIni | foreach-object { if (($_.split("="))[0] -eq "BadItemLimit") { $BadItemLimit = ($_.split("="))[1] } }	

$DefaultEXAdmin = "$env:USERDOMAIN\$env:USERNAME"
$MsgBoxTitle = "Exchange Mail Box Archive Tool - By Justin Hernandez"
#Create The Log directory if does not exist
$LogDir = Join-Path $scriptRoot "Logs"
if (!(Test-Path $LogDir)){New-Item -Path $logDir -Type directory -Force -Confirm:$false| Out-Null}
# -----------------------------------------------------------------------------

function GenerateForm {

#region Import the Assemblies
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
#endregion

#region Generated Form Objects
$ExMailArchive = New-Object System.Windows.Forms.Form
$GrpDelete = New-Object System.Windows.Forms.GroupBox
$Global:RDelNo = New-Object System.Windows.Forms.RadioButton
$Global:RDelYes = New-Object System.Windows.Forms.RadioButton
$lblDelete = New-Object System.Windows.Forms.Label
$Global:txtOutput = New-Object System.Windows.Forms.TextBox
$bPSTOpen = New-Object System.Windows.Forms.Button
$txtPSTLoc = New-Object System.Windows.Forms.TextBox
$bExit = New-Object System.Windows.Forms.Button
$bRun = New-Object System.Windows.Forms.Button
$lblPSTLoc = New-Object System.Windows.Forms.Label
$txtExAdmin = New-Object System.Windows.Forms.TextBox
$txtMailBox = New-Object System.Windows.Forms.TextBox
$lblExAdmin = New-Object System.Windows.Forms.Label
$lblMailBox = New-Object System.Windows.Forms.Label
$lblTitle = New-Object System.Windows.Forms.Label
$MsgBoxError = [Windows.Forms.MessageBox]
$MsgBoxPSTExist = [Windows.Forms.MessageBox]
$savePSTDialog = New-Object System.Windows.Forms.SaveFileDialog
$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState
#endregion Generated Form Objects

#----------------------------------------------
#Generated Event Script Blocks
#----------------------------------------------
#Provide Custom Code for events specified in PrimalForms.
$handler_ExMailArchive_Load= 
{
#TODO: Place custom script here

}

$handler_bPSTOpen_Click= 
{
#TODO: Place custom script here
$savePSTDialog.ShowDialog()
}

$handler_savePSTDialog_FileOk= 
{
#TODO: Place custom script here
$txtPSTLoc.Text = $savePSTDialog.FileName
}

$bExit_OnClick= 
{
#TODO: Place custom script here
Remove-PSSnapin Microsoft.Exchange*
$ExMailArchive.close()
}

$bRun_OnClick= 
{
	#TODO: Place custom script here
	$Global:strMBAlias = $null
	$Global:PSTOverWrite = $false
	$Global:ArrErrMsg = @()
	$UserMailBox = $txtMailBox.text
	$ExchAdmin = $txtExAdmin.text
	$PSTFile = $txtPSTLoc.text
	if ($Global:RDelNo.checked)
	{
		$Global:bDel = $false
	} elseif ($Global:RDelYes.checked)
	{
		$Global:bDel = $true
	}
	if (Validate-allInput $UserMailBox $PSTFile)
	{
		if (!(Check-ExistingPSTFile $PSTFile))
		{
			Run-Export $UserMailBox $ExchAdmin $PSTFile
		} else {
			$ExMailArchive.Cursor = [System.Windows.Forms.Cursors]::Default
			$OverWrite = $MsgBoxPSTExist::Show("$PSTFile already exists. OK to over-write it?", $MsgBoxTitle, "YesNo", "Question")
			if ($OverWrite -eq "Yes")
			{
				$Global:PSTOverWrite = $true
				Run-Export $UserMailBox $ExchAdmin $PSTFile
			} else {
			$txtPSTLoc.selectall()
			$txtPSTLoc.Focus()
			}
		}
	} else {
		$txtResult = "Error:`n "
		foreach ($item in $Global:ArrErrMsg) { $txtResult = $txtResult + "`n - $item" }
		$txtResult = $txtResult + "`n `nPlease fix above item(s) and resubmit the request!"
		$ExMailArchive.Cursor = [System.Windows.Forms.Cursors]::Default
		$MsgBoxError::Show($txtResult, $MsgBoxTitle, "OK", "Error")
	}
}

$OnLoadForm_StateCorrection=
{#Correct the initial state of the form to prevent the .Net maximized form issue
	$ExMailArchive.WindowState = $InitialFormWindowState
}

#----------------------------------------------
#region Generated Form Code
$ExMailArchive.Text = "Exchange Mail Box Archive Tool - By Justin Hernandez"
$ExMailArchive.Name = "ExMailArchive"
$ExMailArchive.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 641
$System_Drawing_Size.Height = 608
$ExMailArchive.ClientSize = $System_Drawing_Size
$ExMailArchive.add_Load($handler_ExMailArchive_Load)

$GrpDelete.Name = "GrpDelete"

$GrpDelete.Text = "Delete All Messages"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 196
$System_Drawing_Size.Height = 58
$GrpDelete.Size = $System_Drawing_Size
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 235
$System_Drawing_Point.Y = 290
$GrpDelete.Location = $System_Drawing_Point
$GrpDelete.TabStop = $False
$GrpDelete.TabIndex = 14
$GrpDelete.DataBindings.DefaultDataSourceUpdateMode = 0
$GrpDelete.Font = New-Object System.Drawing.Font("Arial Narrow",11.25,0,3,0)

$ExMailArchive.Controls.Add($GrpDelete)
$Global:RDelNo.TabIndex = 10
$Global:RDelNo.Name = "RDelNo"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 68
$System_Drawing_Size.Height = 24
$Global:RDelNo.Size = $System_Drawing_Size
$Global:RDelNo.UseVisualStyleBackColor = $True

$Global:RDelNo.Text = "No"
$Global:RDelNo.Font = New-Object System.Drawing.Font("Arial Narrow",9.75,0,3,0)
$Global:RDelNo.Checked = $True

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 113
$System_Drawing_Point.Y = 21
$Global:RDelNo.Location = $System_Drawing_Point
$Global:RDelNo.DataBindings.DefaultDataSourceUpdateMode = 0
$Global:RDelNo.TabStop = $True

$GrpDelete.Controls.Add($Global:RDelNo)

$Global:RDelYes.TabIndex = 9
$Global:RDelYes.Name = "RDelYes"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 68
$System_Drawing_Size.Height = 21
$Global:RDelYes.Size = $System_Drawing_Size
$Global:RDelYes.UseVisualStyleBackColor = $True

$Global:RDelYes.Text = "Yes"
$Global:RDelYes.Font = New-Object System.Drawing.Font("Arial Narrow",9.75,0,3,0)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 20
$System_Drawing_Point.Y = 21
$Global:RDelYes.Location = $System_Drawing_Point
$Global:RDelYes.DataBindings.DefaultDataSourceUpdateMode = 0

$GrpDelete.Controls.Add($Global:RDelYes)

$lblDelete.TabIndex = 8
$lblDelete.TextAlign = 16
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 166
$System_Drawing_Size.Height = 32
$lblDelete.Size = $System_Drawing_Size
$lblDelete.Text = "Delete After Export:"
$lblDelete.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 307
$lblDelete.Location = $System_Drawing_Point
$lblDelete.DataBindings.DefaultDataSourceUpdateMode = 0
$lblDelete.Name = "lblDelete"

$ExMailArchive.Controls.Add($lblDelete)

$Global:txtOutput.Multiline = $True
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 564
$System_Drawing_Size.Height = 137
$Global:txtOutput.Size = $System_Drawing_Size
$Global:txtOutput.DataBindings.DefaultDataSourceUpdateMode = 0
$Global:txtOutput.ReadOnly = $True
$Global:txtOutput.ScrollBars = 3
$Global:txtOutput.Name = "txtOutput"
$Global:txtOutput.WordWrap = $false
$Global:txtOutput.Font = New-Object System.Drawing.Font("Arial",11.25,0,3,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 363
$Global:txtOutput.Location = $System_Drawing_Point
$Global:txtOutput.ForeColor = [System.Drawing.Color]::FromArgb(255,0,192,0)
$Global:txtOutput.TabIndex = 11
$Global:txtOutput.Text = ""

$ExMailArchive.Controls.Add($Global:txtOutput)

$bPSTOpen.TabIndex = 7
$bPSTOpen.Name = "bPSTOpen"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 34
$System_Drawing_Size.Height = 27
$bPSTOpen.Size = $System_Drawing_Size
$bPSTOpen.UseVisualStyleBackColor = $True

$bPSTOpen.Text = "..."
$bPSTOpen.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 561
$System_Drawing_Point.Y = 245
$bPSTOpen.Location = $System_Drawing_Point
$bPSTOpen.DataBindings.DefaultDataSourceUpdateMode = 0
$bPSTOpen.add_Click($handler_bPSTOpen_Click)

$ExMailArchive.Controls.Add($bPSTOpen)

$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 300
$System_Drawing_Size.Height = 26
$txtPSTLoc.Size = $System_Drawing_Size
$txtPSTLoc.DataBindings.DefaultDataSourceUpdateMode = 0
$txtPSTLoc.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)
$txtPSTLoc.Name = "txtPSTLoc"
$txtPSTLoc.Text = ""
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 236
$System_Drawing_Point.Y = 245
$txtPSTLoc.Location = $System_Drawing_Point
$txtPSTLoc.TabIndex = 6

$ExMailArchive.Controls.Add($txtPSTLoc)

$bExit.TabIndex = 13
$bExit.Name = "bExit"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 148
$System_Drawing_Size.Height = 39
$bExit.Size = $System_Drawing_Size
$bExit.UseVisualStyleBackColor = $True

$bExit.Text = "Exit"
$bExit.Font = New-Object System.Drawing.Font("Arial",12,1,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 368
$System_Drawing_Point.Y = 517
$bExit.Location = $System_Drawing_Point
$bExit.DataBindings.DefaultDataSourceUpdateMode = 0
$bExit.add_Click($bExit_OnClick)

$ExMailArchive.Controls.Add($bExit)

$bRun.TabIndex = 12
$bRun.Name = "bRun"
$bRun.Enabled = $true
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 148
$System_Drawing_Size.Height = 39
$bRun.Size = $System_Drawing_Size
$bRun.UseVisualStyleBackColor = $True

$bRun.Text = "Run"
$bRun.Font = New-Object System.Drawing.Font("Arial",12,1,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 110
$System_Drawing_Point.Y = 517
$bRun.Location = $System_Drawing_Point
$bRun.DataBindings.DefaultDataSourceUpdateMode = 0
$bRun.add_Click($bRun_OnClick)

$ExMailArchive.Controls.Add($bRun)

$lblPSTLoc.TabIndex = 5
$lblPSTLoc.TextAlign = 16
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 166
$System_Drawing_Size.Height = 31
$lblPSTLoc.Size = $System_Drawing_Size
$lblPSTLoc.Text = "PST File Location:"
$lblPSTLoc.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 243
$lblPSTLoc.Location = $System_Drawing_Point
$lblPSTLoc.DataBindings.DefaultDataSourceUpdateMode = 0
$lblPSTLoc.Name = "lblPSTLoc"

$ExMailArchive.Controls.Add($lblPSTLoc)

$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 359
$System_Drawing_Size.Height = 26
$txtExAdmin.Size = $System_Drawing_Size
$txtExAdmin.DataBindings.DefaultDataSourceUpdateMode = 0
$txtExAdmin.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)
$txtExAdmin.Name = "txtExAdmin"
$txtExAdmin.Text = ""
$txtExAdmin.ReadOnly = $True
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 236
$System_Drawing_Point.Y = 184
$txtExAdmin.Location = $System_Drawing_Point
$txtExAdmin.TabIndex = 4
$txtExAdmin.text = $DefaultEXAdmin
$ExMailArchive.Controls.Add($txtExAdmin)

$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 360
$System_Drawing_Size.Height = 26
$txtMailBox.Size = $System_Drawing_Size
$txtMailBox.DataBindings.DefaultDataSourceUpdateMode = 0
$txtMailBox.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)
$txtMailBox.Name = "txtMailBox"
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 235
$System_Drawing_Point.Y = 125
$txtMailBox.Location = $System_Drawing_Point
$txtMailBox.TabIndex = 2

$ExMailArchive.Controls.Add($txtMailBox)

$lblExAdmin.TabIndex = 3
$lblExAdmin.TextAlign = 16
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 166
$System_Drawing_Size.Height = 31
$lblExAdmin.Size = $System_Drawing_Size
$lblExAdmin.Text = "Exchange Admin:"
$lblExAdmin.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 184
$lblExAdmin.Location = $System_Drawing_Point
$lblExAdmin.DataBindings.DefaultDataSourceUpdateMode = 0
$lblExAdmin.Name = "lblExAdmin"

$ExMailArchive.Controls.Add($lblExAdmin)

$lblMailBox.TabIndex = 1
$lblMailBox.TextAlign = 16
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 166
$System_Drawing_Size.Height = 31
$lblMailBox.Size = $System_Drawing_Size
$lblMailBox.Text = "User Mailbox:"
$lblMailBox.Font = New-Object System.Drawing.Font("Arial",12,0,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 31
$System_Drawing_Point.Y = 122
$lblMailBox.Location = $System_Drawing_Point
$lblMailBox.DataBindings.DefaultDataSourceUpdateMode = 0
$lblMailBox.Name = "lblMailBox"

$ExMailArchive.Controls.Add($lblMailBox)

$lblTitle.TabIndex = 0
$lblTitle.TextAlign = 32
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 613
$System_Drawing_Size.Height = 72
$lblTitle.Size = $System_Drawing_Size
$lblTitle.Text = "Exchange Server Mailbox Archive Tool"
$lblTitle.Font = New-Object System.Drawing.Font("Arial",18,1,3,1)

$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 12
$System_Drawing_Point.Y = 9
$lblTitle.Location = $System_Drawing_Point
$lblTitle.DataBindings.DefaultDataSourceUpdateMode = 0
$lblTitle.Name = "lblTitle"

$ExMailArchive.Controls.Add($lblTitle)

$savePSTDialog.ValidateNames =$false
$savePSTDialog.CheckPathExists =$false
$savePSTDialog.Filter = "PST File (*.pst)|*.pst|All Files (*.*)|*.*"
$savePSTDialog.ShowHelp = $True
$savePSTDialog.CreatePrompt = $false
$savePSTDialog.CheckFileExists = $false
$savePSTDialog.Title = "Choose Location for the PST file"
$savePSTDialog.DefaultExt = "pst"
$savePSTDialog.InitialDirectory = "C:\"
$savePSTDialog.RestoreDirectory = $true
$savePSTDialog.add_FileOk($handler_savePSTDialog_FileOk)

#endregion Generated Form Code

#Save the initial state of the form
$InitialFormWindowState = $ExMailArchive.WindowState
#Init the OnLoad event to correct the initial state of the form
$ExMailArchive.add_Load($OnLoadForm_StateCorrection)
#Show the Form
$ExMailArchive.ShowDialog()| Out-Null

} #End Function

function Write-FormOutput ([string]$strMsg)
{
	if ($Global:txtOutput.text -ne "")
	{$Global:txtOutput.text =$Global:txtOutput.text + "
$strMsg"} else {$Global:txtOutput.text = $strMsg}
Add-Content -Path $LogFile -Value $strMsg
}

function Process-Result ($objExportMB)
{
	$arrResult = @()
	foreach ($p in Get-Member -InputObject $objExportMB -MemberType Property)
	{
		$arrResult += $p.name+": "+$ExportMB.($p.name)
	}
	Return $arrResult
}

########################Begin Validation functions######################################
function Validate-Mailbox ([String]$strMailBox)
{
	$bValidMB = $false
	$objMB =Get-Mailbox $strMailBox
	if ($objMB) {$bValidMB = $true; $Global:strMBAlias = $objMB.alias}
	Return $bValidMB
}

function Validate-PSTLocation ([String]$strLoc)
{
	$BvalidLoc = $false
	#Firstly, check if the parent folder is in valid
	if ((Split-Path $strLoc) -ne "")
	{
		$BvalidLoc = Test-Path (Split-Path $strLoc)
	} 

	#secondly, check if the file specified has a .PST extention
	if ((Split-Path $StrLoc -leaf).length -le 4 -or (Split-Path $StrLoc -leaf).substring((Split-Path $StrLoc -leaf).length -4, 4) -ine ".pst")
	{
		$BvalidLoc = $false
	}
	
	Return $BvalidLoc
}

function Check-ExistingPSTFile ($strLoc)
{
	$BPSTExist = Test-Path $strLoc
	Return $BPSTExist
}

function Validate-AllInput ([string]$strMailBox, [String]$strLoc)
{
	$bAllValid = $true
	$ValidateMB = Validate-Mailbox $strMailBox
	$ValidatePSTPath = Validate-PSTLocation $strLoc
	if ($ValidateMB -eq $false)
	{
		$bAllValid = $false
		$Global:ArrErrMsg += "The mailbox cannot be found!"
	}
	
	if ($ValidatePSTPath -eq $false)
	{
		$bAllValid = $false
		$Global:ArrErrMsg += "The PST file save path is invalid!"
	}
	Return $bAllValid
}
########################End Validation functions######################################

function Exporting ([String]$UserMailBox, [String]$ExchAdmin, [String]$PSTFile) 
{
	$Date = Get-Date
	$LogFile = Join-Path $LogDir "$Global:strMBAlias-$env:USERNAME-$($Date.Day).$($Date.Month).$($Date.year).$(($Date.TimeOfDay).ToString().replace(":",".")).Log"
	New-Item -Path $LogFile -type "file" -Force -Value "$($Date.DateTime): Mailbox Export for $UserMailBox, Initiated by $ExchAdmin."
	Add-Content -Path $LogFile -Value "`n"
	$errAddPermission = $null
	$errExportMB = $null
	$errRemovePermission = $null
	$bStop = $false
	$bMBPermissionRemoveRequired = $false
	
	Write-FormOutput "Start Time: $((Get-date).DateTime)"
	#temporarily assign "FullAccess" permission to the mailbox for the export operation
	if ((Get-MailboxPermission -Identity $UserMailBox -User $ExchAdmin).AccessRights -inotmatch "fullaccess")
	{
		#assign $bMBPermissionRemoveRequired to $true so the full access permission will be removed later on
		$bMBPermissionRemoveRequired = $true
		Write-FormOutput "- Setting access rights for $ExchAdmin."
		Add-MailboxPermission -Identity $UserMailBox -User $ExchAdmin -AccessRights FullAccess -Confirm:$False -ErrorVariable errAddPermission
		if ($errAddPermission -ne $null) {Write-FormOutput "- Error: $errAddPermission"; $bStop = $true}
	} else {
		Write-FormOutput "- INFO: $ExchAdmin already has full access to $UserMailBox."
	}
	
	if ($bStop -eq $false)
	{
		Write-FormOutput "- Exporting into file $($PSTFile.ToUpper())."
		if ($Global:PSTOverWrite -eq $true)
		{
			Write-FormOutput "- $PSTFile previously exists, it will be overwritten!"
			if (Test-Path $PSTFile) {Remove-Item $PSTFile -Force}
		}
		$ExportMB = Export-Mailbox -Identity $UserMailBox -PSTFolderPath $PSTFile -MaxThreads $Threads -BadItemLimit $BadItemLimit -DeleteContent:$Global:bDel -Confirm:$False -ErrorVariable errExportMB
		if ($errExportMB -ne $null) {Write-FormOutput "- Error: $errExportMB"; $bStop = $true}
	}
	
	if ($bMBPermissionRemoveRequired -eq $true)
	{
		if ($bStop -eq $false)
		{	
			Write-FormOutput "- Removing access rights for $ExchAdmin."
			Remove-MailboxPermission -Identity $UserMailBox -User $ExchAdmin -AccessRights FullAccess -InheritanceType All -Confirm:$False -ErrorVariable errRemovePermission
			if ($errRemovePermission -ne $null) {Write-FormOutput "- Error: $errRemovePermission"; $bStop = $true}
		}
	} else {
		Write-FormOutput "- INFO: No need to remove access rights for $ExchAdmin as it was already present prior to the export."
	}
	if ($bStop -eq $false)
	{
		Write-FormOutput "- Done!"
		Write-FormOutput "End Time: $((Get-date).DateTime)"
		Write-FormOutput "Log File: $logfile"
		Write-FormOutput "Result:"
		Write-FormOutput "----------------------"
		$arrResult = Process-result $ExportMB
		Foreach($item in $arrResult){Write-FormOutput $item}
	} else {
		Write-FormOutPut "- Operation Aborted!"
		Write-FormOutput "End Time: $((Get-date).DateTime)"
		Write-FormOutput "Log File: $logfile"
	}

	Remove-Variable errAddPermission, errExportMB, errRemovePermission
	
}
function Run-Export ($UserMailBox, $ExchAdmin, $PSTFile)
{
	$Global:txtOutput.text = ""
	$bRun.Enabled = $false
	Exporting $UserMailBox $ExchAdmin $PSTFile
	$bRun.Enabled = $true
}

#Call the Function
GenerateForm
