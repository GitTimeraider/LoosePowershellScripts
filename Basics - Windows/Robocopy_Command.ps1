# Robocopy and cleanup script
# Patrick Berger - Madnessshell.com

Remove-Item -Path c:\temp\robocopylog.txt -force -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Path c:\temp\robocopylog2.txt -force -ErrorAction SilentlyContinue | Out-Null
$path = "C:\temp\empty"
If(!(test-path -PathType container $path))
{
      New-Item -ItemType Directory -Path $path -Force -ErrorAction SilentlyContinue | Out-Null
}
write-host "Robocopy script"
write-host "Written by: Patrick Berger - Madnessshell.com"
$source = Read-Host -Prompt 'Input sourcefolder path (Example: F:\Shares\Projecten\2021)'
$option = Read-Host -Prompt 'Robocopy or sourcefolder cleanup-only? Type ROBOCOPY for the copy or CLEANUP for cleanup-only'
if($option -eq "ROBOCOPY"){}
elseif($option -eq "CLEANUP"){robocopy C:\temp\empty $source /MIR /NP
      Remove-Item -Path $source -force -Recurse
      write-host "Sourcefolder has been cleaned and deleted. Exiting"
      Pause
      Remove-Item -Path $path -force -Recurse
exit}
else{write-host "No option has been chosen"
Pause
Remove-Item -Path $path -force -Recurse
exit}
$target = Read-Host -Prompt 'Input targetfolder path (Example: F:\Shares\Projecten\2021)'
write-host "This script is delivered AS IS and under the pretext of best effort. No rights can be attained from this."
write-host " "
robocopy $source $target /e /MT:32 /LOG:c:\temp\robocopylog.txt /TEE /NP /r:5 /w:60
write-host "Retrying files that got access denied with different parameters"
robocopy $source $target /e /MT:32 /LOG:c:\temp\robocopylog2.txt /TEE /NP /r:5 /w:60 /NODCOPY
write-host "A log has been created at: c:\beheer\robocopylog.txt and c:\beheer\robocopylog2.txt"
$clean = Read-Host -Prompt 'Type YES if you want to clean and delete the sourcefolder? (If there are many access denied messages for the last run, do not do this untill it is resolved!)'
if($clean -eq "YES"){robocopy C:\temp\empty $source /MIR /NP
      Remove-Item -Path $source -force -Recurse
      write-host "Sourcefolder has been cleaned and deleted"}
else{write-host "No cleaning executed"}
Remove-Item -Path $path -force -Recurse
Pause