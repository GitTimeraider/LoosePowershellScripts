# Description: This script will install all available updates and hide the updates that are specified in the environment variables.
# Patrick Berger - Madnessshell.com


#Install modules
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -name NuGet -minimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

write-host "Updates which are ready:"
Get-WUList
write-host "--------------------------------------------"
write-host "--------------------------------------------"
write-host " "

if ($env:HideUpdatename -ne "EMPTY"){
$lists = $env:HideUpdatename.split(",");
foreach($Name in $lists){
Write-host "Trying to hide $Name"
Hide-WindowsUpdate -Title "$Name*" -Confirm:$false}
}

if ($env:HideKBNumber -ne "EMPTY") {
$lists2 = $env:HideKBNumber.split(",");
foreach($number in $lists2){
    Write-host "Trying to hide $number"
Hide-Windowsupdate -KBArticleID $number -Confirm:$false
}}

write-host "--------------------------------------------"
write-host "--------------------------------------------"
write-host " "

Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot | Out-File C:\temp\PSWindowsUpdate.log
