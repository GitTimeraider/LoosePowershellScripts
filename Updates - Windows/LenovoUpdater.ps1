# Component to update firmware/BIOS on Lenovo devices
# Patrick Berger - Madnessshell.com


Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name 'LSUClient' -Force
Import-Module LSUClient
$env:TEMP = "c:\temp"
$Datum = Get-Date -Format "dd-MM-yyyy"

Stop-Transcript | out-null
New-Item -Path "c:\temp" -Name "Lenovo" -ItemType "directory"
Start-Transcript -path "c:\temp\Lenovo\($Datum).txt" -append

if ($env:Option -like "Install") {
    write-host "Install started"
    $updates = Get-LSUpdate | Where-Object { $_.Installer.Unattended }
    $updates | Save-LSUpdate -Verbose
    $updates | Install-LSUpdate -Verbose -SaveBIOSUpdateInfoToRegistry
}
Else {
    write-host "Analyze started"
    $updates = Get-LSUpdate | Where-Object { $_.Installer.Unattended }
    $updates | Save-LSUpdate
    Write-host " "
    Write-host "Update IDs found"
    Get-ChildItem -Path C:\temp\LSUPackages -Directory -Force -ErrorAction SilentlyContinue | Select-Object Name
    Remove-Item 'C:\temp\LSUPackages' -Recurse -Force   
}
Stop-Transcript

if ($env:Reboot -like "Enabled") {
    write-host "Reboot option choosen"
    & shutdown.exe /r /f /d p:0:0 /c "Planned by Firmware/BIOS updates. Reboot will occur in 5 minutes. Provided by the Managed Services team of Datamex Automatisering" /t 300
}
Else {
    write-host "No reboot choosen"
}