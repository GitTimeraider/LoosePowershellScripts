# Update and install Windows updates
# Patrick Berger - Madnessshell.com

#Install modules
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Import-Module PSWindowsUpdate

Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
$Rebootstatus = Get-WURebootStatus
if ($Rebootstatus.RebootRequired -match "False")
{write-host "No Reboot Required"}
Elseif ($Rebootstatus.RebootRequired -match "True") {write-host "Reboot required"
Restart-Computer
}
else{write-host "No rebootstatus could be retrieved"}