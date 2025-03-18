# Windows Update - Full fix package
# This script will reset the Windows Update components and services to their default settings.
# Patrick Berger - Madnessshell.com

#Run as administrator

$ErrorActionPreference = 'SilentlyContinue'

Move-Item -Path .\Reset_Windows_Update_Full.bat -Destination C:\Beheer -force

c:\Beheer\Reset_Windows_Update_Full.bat

net stop wuauserv
net stop bits
net stop appidsvc
net stop cryptsvc

Remove-Item -path C:\ProgramData\Microsoft\Network\Downloader -recurse

Remove-Item -path c:\windows\SoftwareDistribution -recurse

net start wuauserv
net start bits
net start appidsvc
net start cryptsvc