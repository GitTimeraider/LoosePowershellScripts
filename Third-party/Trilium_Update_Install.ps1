#Update/Install TriliumNext Notes for Windows x64
#Written by: Patrick Berger - Madnessshell.com

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

##You can adjust below values##
$installationloc = "C:\Program Files"
$Installationfolder = "Trilium"
$temploc = "c:\temp"

#########Creation of functions#############

function Downloadfile {
    remove-Item "$temploc\Trilium.zip" -force
    $urllink = "https://github.com/TriliumNext/Notes/releases/download/v$version/TriliumNextNotes-v$version-windows-x64.zip"
    Invoke-WebRequest -Uri $urllink -OutFile "$temploc\Trilium.zip" -UseBasicParsing
    Start-Sleep -Seconds 10
    if ( Test-Path "$temploc\Trilium.zip" ) {
        write-host "File downloaded succesfully"
    }
    else {
        write-host "File couldnt be downloaded. Installation/Update has been stopped"
        Pause
    } 
}

function Update {
    
    $version2 = (Get-Item "$installationloc\$Installationfolder\trilium.exe").VersionInfo.FileVersion
    [version]$versionnew = $version
    [version]$versionold = $version2
    If ($versionnew -gt $versionold) {
        Write-host "New version of Trilium available"
        Write-host "$version is being downloaded from $url"
        Write-host "Local version: $version2 - Online version: $version"
        Downloadfile
        Get-Process | Where-Object { $_.Name -like "trilium" } | Stop-Process -force
        Remove-Item -Recurse -Force "$installationloc\$Installationfolder"
        Expand-Archive -LiteralPath "$temploc\Trilium.zip" -DestinationPath "$installationloc\$Installationfolder"
        Write-host "Update commands are done"
        Pause
    }
    elseif ($versionnew -eq $versionold) {
        write-host "Versions match. Latest version is installed."
        Write-host "Local version: $version2 - Online version: $version"
        $confirmation = Read-Host "If there are issues, do you want to repair the installation? (y/n)"
        if ($confirmation -eq 'y') {
            Downloadfile
            Get-Process | Where-Object { $_.Name -like "trilium" } | Stop-Process -force
            Remove-Item -Recurse -Force "$installationloc\$Installationfolder"
            Expand-Archive -LiteralPath "$temploc\Trilium.zip" -DestinationPath "$installationloc\$Installationfolder"
            Write-host "Repair is done"
            Pause
        }
        else {
        }
    }
    else {
        write-host "Either the local version is higher than the latest online one or there has been a different error"
        Write-host "Local version: $version2 - Online version: $version"
        Write-host "Error:"
        Get-Error
        Pause
    }
}
function Installation {
    Downloadfile
    New-Item -Path "$installationloc\" -Name $Installationfolder -ItemType Directory
    Expand-Archive -LiteralPath "$temploc\Trilium.zip" -DestinationPath "$installationloc\$Installationfolder"
    Write-host "Installation commands are done"
    Pause
}

###########Script############

#Retrieve versions and urls
$Webpagina = Invoke-WebRequest "https://github.com/TriliumNext/Notes/releases/latest" -UseBasicParsing
$content = Select-String -InputObject $Webpagina.Content -Pattern "/TriliumNext/Notes/releases/tag/" | Select-object -First 1
$content -match '/TriliumNext/Notes/releases/tag/v\d+.\d+.\d+.' | Out-Null
$url = $Matches[0]
$url -match '\d+.\d+.\d+' | Out-Null
$version = $Matches[0]

if ( Test-Path "$installationloc\$Installationfolder" ) {
    write-host "Trilium is installed. Checking version"
    Update
}
else {
    write-host "$installationloc\$Installationfolder does not exist."
    $confirmation = Read-Host "Are you Sure You Want To Proceed: (y/n)"
    if ($confirmation -eq 'y') {
        Installation
    }
    else {
        write-host "Installation declined"
        exit 0
    }
}