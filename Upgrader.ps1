#Windows 10 In Place Upgrade Script
#Last Updated 1/19/20
#Nathaniel Bannister

$updateNetworkPath = "\\Testpc\E$\W10-1909\"
$webPath = "http://192.168.1.196/"
$localWorkingDir = "C:\Windows10Upgrade\"
$x64 = "Win10_1909_English_x64"
$x64hash = "9DC9CD4D956C51FDAA9ECD0F86FDF0A1E35526D9"
$x32 = "Win10_1909_English_x32"
$x32hash = "dccc9ca8de92d45495bd69e6895095e189c1d5dd"

$UpdateEXE = "setup.exe"
$UpdateArguments = "/auto upgrade /DynamicUpdate Enable /quiet"

Import-Module BitsTransfer

$activated = (cscript /Nologo "C:\Windows\System32\slmgr.vbs" /xpr) -join ''
$addressWidth = $(Get-WmiObject Win32_Processor).AddressWidth

Write-Host "Starting Upgrade Process... v1.2"
if (($activated -like '*is permanently activated*')){
    Write-Host "System is Activated - Proceeding"
    if ($addressWidth -eq "64"){
        Write-Host "64-Bit Windows Detected - Proceeding"
        $referenceISOHash = $x64hash
        $updateNetworkPath = $updateNetworkPath + $x64
        $updateWebPath = $webPath + $x64 + ".iso"
        $7zipwebpath = $webPath + "/7z.exe"
        $localPath = $localWorkingDir + $x64
        $localISOPath = $localWorkingDir + $x64 + ".iso"
    }elseif($addressWidth -eq "32"){
        Write-Host "32-Bit Windows Detected - Proceeding"
        $referenceISOHash = $x32hash
        $updateNetworkPath = $updateNetworkPath + $x64
        $updateWebPath = $webPath + $x32 + ".iso"
        #Swap 7z EXE out for x86 version later!
        $7zipwebpath = $webPath + "7z.exe"
        $localPath = $localWorkingDir + $x32
        $localISOPath = $localWorkingDir + $x32 + ".iso"
    }else{exit}
} else {
    Write-Host "System isn't activated - Aborting"
    exit
}

$UpdateExePath = $updateNetworkPath+"\"+$UpdateEXE
if (Test-Path ($UpdateExePath)){
    #If UNC Path is Valid - Install from Network
    Write-Host "Network Path ($UpdateExePath) is Valid - Starting Update from Network!"
    Write-Host "Starting Upgrade" $UpdateExePath $UpdateArguments

    Start-Process -FilePath $UpdateExePath -ArgumentList $UpdateArguments
} else {
    Write-Host "Network Path ($UpdateExePath) is Invalid - Checking for Local Files"
    #Make sure 7-Zip is in the Working Directory - If it Fails, create the working directory then download.
    $7zippath = $localWorkingDir + "7z.exe"
    if ((Test-Path $7zippath)){
        Write-Host "7z is Ready!"
        } else {
            Write-Host "Creating Working Directory ($localWorkingDir):"
            New-Item -Path "c:\" -Name "Windows10Upgrade" -ItemType "directory"

            Write-Host "7z Missing - Downloading"
            
            $startTime = Get-Date
            Start-BitsTransfer -Source $7zipwebpath -Destination $7zippath
            $duration = (Get-Date).Subtract($startTime).Seconds
            Write-Output "Download completed in: $duration seconds(s)"
            Write-Host "7z is now Ready!"
        }
        #Is ISO already downloaded? Download if missing.
        if (!(Test-Path $localISOPath)){
        Write-Host "Windows 10 ISO Not Found ($localISOPath) - Downloading"
        $startTime = Get-Date
        
        Start-BitsTransfer -Source $updateWebPath -Destination $localISOPath
        $duration = (Get-Date).Subtract($startTime).Seconds
        Write-Output "Download completed in: $duration seconds(s)"
        } 
    #Verify ISO is uncorrupted.
    Write-Host "ISO Found - Checking SHA1"
    $isohash = $(CertUtil -hashfile $localISOPath SHA1)[1] -replace " ",""
    Write-Host "SHA1 Hash for Downloaded file:" $isohash.Hash
    #If ISO is intact, extract to working directory using 7Z
    if ($isohash.Hash -eq $referenceISOHash){
        Write-Host "ISO Matches - Proceeding"
        Write-Host "Extracting ISO..."
        Start-Process -FilePath $7zippath -ArgumentList " x -y -o$localPath $localISOPath" -Wait
        #ISO Extracted - Lets Update!
        $UpdateExePath = $localPath+"\"+$UpdateEXE
        Write-Host "Starting Upgrade" $UpdateExePath $UpdateArguments
        Start-Process -FilePath $UpdateExePath -ArgumentList $UpdateArguments -Wait
    } else {
        Write-Host "ISO Mismatch, Aborting"
        Write-Host $isohash.Hash "doesn't match" $referenceISOHash
        exit
    }
}