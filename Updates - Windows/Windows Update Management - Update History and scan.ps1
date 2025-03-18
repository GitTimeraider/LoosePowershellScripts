# List of successful and failed updates in the last 30 days and list of updates ready to be installed
# Patrick Berger - Madnessshell.com

#Install modules
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -name NuGet -minimumVersion 2.8.5.201 -Force
Install-Module -Name PSWindowsUpdate -Force
Import-Module PSWindowsUpdate

write-host "----------------------------"
write-host "----------------------------"
write-host "----------------------------"
write-host "History of successfull updates:"
Get-WUHistory -MaxDate (Get-Date).AddDays(-30) -Last 100 | where-object Result -ne "Failed" | Select-Object title,Date,Result | Format-List
write-host "-------------------------------"
write-host "-------------------------------"
write-host "History of failed updates:"
Get-WUHistory -MaxDate (Get-Date).AddDays(-30) -Last 100 | where-object Result -eq "Failed" | Select-Object title,Date,Result | Format-List
write-host "----------------------------"
write-host "----------------------------"
write-host "----------------------------"

write-host "Updates ready to be installed:"
Get-WUList