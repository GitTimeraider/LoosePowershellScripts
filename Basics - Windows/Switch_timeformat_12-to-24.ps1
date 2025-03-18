# Description: This script will change the time format from 12 to 24 hours for all users on a Windows system.
#Patrick Berger - Madnessshell.com

function Set-RegistryValueForAllUsers {
    
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true)]
		[hashtable[]]$RegistryInstance
	)
	try {
		New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null
		
		$LoggedOnSids = (Get-ChildItem HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName
		Write-Verbose "Found $($LoggedOnSids.Count) logged on user SIDs"
		foreach ($sid in $LoggedOnSids) {
			Write-Verbose -Message "Loading the user registry hive for the logged on SID $sid"
			foreach ($instance in $RegistryInstance) {            
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

$Valuename = "iTime"
$RegistryType = "String"
$Waarde = "1"
$Pad = "\Control Panel\International"
#Alleen hier hoeven onderdelen aangepast te worden
Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = $Valuename; 'Type' = $RegistryType; 'Value' = $Waarde; 'Path' = $Pad}

$Valuename = "sShortTime"
$Waarde = "HH:mm"
#Alleen hier hoeven onderdelen aangepast te worden
Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = $Valuename; 'Type' = $RegistryType; 'Value' = $Waarde; 'Path' = $Pad}

$Valuename = "sTimeFormat"
$Waarde = "HH:mm:ss"
#Alleen hier hoeven onderdelen aangepast te worden
Set-RegistryValueForAllUsers -RegistryInstance @{'Name' = $Valuename; 'Type' = $RegistryType; 'Value' = $Waarde; 'Path' = $Pad}