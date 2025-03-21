﻿# Description: This script will set a registry value for all users that are currently logged on to the system.
# Patrick Berger - Madnessshell.com

$Valuename = 'ValueName'
$RegistryType = 'Dword'
$Regvalue = '0'
$Regpath = 'Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
$AboveFolder = 'Yes' #If the folder above the path does not exist, should it be created? (Yes/No)

function Set-RegistryValueForAllUsers {
    
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[hashtable[]]$RegistryInstance
	)
	try {
		New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
		
		$LoggedOnSids = (Get-ChildItem HKU: | where { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName
		Write-Verbose "Found $($LoggedOnSids.Count) logged on user SIDs"
		foreach ($sid in $LoggedOnSids) {
			Write-Verbose -Message "Loading the user registry hive for the logged on SID $sid"
			foreach ($instance in $RegistryInstance) {
              ## !!!Maakt bovenliggende map aan mocht deze niet bestaan. Wanneer bovenstaande map al bestaat zal hij deze overnieuw aanmaken en dus alle keys 
              ##  verwijderen!!! Deze variabele moet dus alleen worden beantwoord met "Nee" als er echt geen bovenliggende map is!                
              if ($AboveFolder -like "No") {New-Item -Path "HKU:\$sid\$($instance.Path | Split-Path -Parent)" -Name ($instance.Path | Split-Path -Leaf) -Force | Out-Null }
	      Set-ItemProperty -Path "HKU:\$sid\$($instance.Path)" -Name $instance.Name -Value $instance.Value -Type $instance.Type -Force
			}
		}
		
		
		Write-Verbose "Setting Active Setup registry value to apply to all other users"
		foreach ($instance in $RegistryInstance) {
			$Guid = [guid]::NewGuid().Guid
			$ActiveSetupRegParentPath = 'HKLM:\Software\Microsoft\Active Setup\Installed Components'
			New-Item -Path $ActiveSetupRegParentPath -Name $Guid -Force | Out-Null
			$ActiveSetupRegPath = "HKLM:\Software\Microsoft\Active Setup\Installed Components\$Guid"
			Write-Verbose "Using registry path '$ActiveSetupRegPath'"

			switch ($instance.Type) {
				'String' {
					$RegValueType = 'REG_SZ'
				}
				'Dword' {
					$RegValueType = 'REG_DWORD'
				}
				'Binary' {
					$RegValueType = 'REG_BINARY'
				}
				'ExpandString' {
					$RegValueType = 'REG_EXPAND_SZ'
				}
				'MultiString' {
					$RegValueType = 'REG_MULTI_SZ'
				}
				default {
					throw "Registry type '$($instance.Type)' not recognized"
				}
			}
			
			$ActiveSetupValue = "reg add `"{0}`" /v {1} /t {2} /d {3} /f" -f "HKCU\$($instance.Path)", $instance.Name, $RegValueType, $instance.Value
			Write-Verbose -Message "Active setup value is '$ActiveSetupValue'"
			Set-ItemProperty -Path $ActiveSetupRegPath -Name '(Default)' -Value 'Active Setup Test' -Force
			Set-ItemProperty -Path $ActiveSetupRegPath -Name 'Version' -Value '1' -Force
			Set-ItemProperty -Path $ActiveSetupRegPath -Name 'StubPath' -Value $ActiveSetupValue -Force
		}
	} catch {
		Write-Warning -Message $_.Exception.Message
	}
}

#Alleen hier hoeven onderdelen aangepast te worden
Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = $Valuename; 'Type' = $RegistryType; 'Value' = $Regvalue; 'Path' = $Regpath}