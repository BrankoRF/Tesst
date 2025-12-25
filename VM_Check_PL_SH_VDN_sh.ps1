		# Povezivanje na ESXi host
		$ESXiHost = Read-Host 'Enter VC Server name'
		$ESXiUsername = Read-Host 'Enter user name'
		$ESXiPassword = Read-Host 'Enter password' -AsSecureString
		Connect-VIServer -Server $ESXiHost -User $ESXiUsername -Password $ESXiPassword
		
		# Ime virtualne mašine
		$VMName = "hofshare2"
		
		# Dobijanje objekta virtualne mašine
		$VM = Get-VM -Name $VMName
		
		# Prikazivanje informacija o fizičkim LUN-ovima, deljenjima i virtualnim uređajima čvorova
		Write-Host "Informacije o fizickim LUN-ovima, deljenjima i virtualnim uredjajima čvorova za virtualnu mašinu: $VMName"
		
		# Prikazivanje fizičkih LUN-ova
		Write-Host "Fizicki LUN-ovi:"
		$VM.ExtensionData.Config.Hardware.Device | Where-Object {$_.DeviceInfo.Label -like "naa.*"} | ForEach-Object {
		    $lun = $_
		    $lunInfo = $lun.DeviceInfo
		    $lunLabel = $lunInfo.Label
		    $lunKey = $lun.Key
		
		    Write-Host "LUN Label: $lunLabel"
		    Write-Host "LUN Key: $lunKey"
		    Write-Host "-----------------------------"
		}
		
		# Prikazivanje deljenja (shares)
		Write-Host "Deljenja (Shares):"
		$VM.ExtensionData.ResourceConfig.Share.Share | ForEach-Object {
		    $share = $_
		    $shareLevel = $share.Level
		    $shareValue = $share.Value
		
		    Write-Host "Level: $shareLevel"
		    Write-Host "Value: $shareValue"
		    Write-Host "-----------------------------"
		}
		
		# Prikazivanje virtualnih uređaja čvorova
		Write-Host "Virtualni uređaji čvorova:"
		$VM.ExtensionData.Config.Hardware.Device | Where-Object {$_.DeviceInfo.Summary -like "Virtual.*"} | ForEach-Object {
		    $device = $_
		    $deviceLabel = $device.DeviceInfo.Label
		    $deviceKey = $device.Key
		
		    Write-Host "Device Label: $deviceLabel"
		    Write-Host "Device Key: $deviceKey"
		    Write-Host "-----------------------------"
		}
		
		# Odjavljivanje sa ESXi hosta
		Disconnect-VIServer -Confirm:$false
