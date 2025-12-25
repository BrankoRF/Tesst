# Učitaj PowerCLI modul
Import-Module VMware.PowerCLI -Force

# Konekcija na vCenter
#$cred = Get-Credential
$vCenter = "hovcenter.rbj.co.yu"  # Promeni ovo
Connect-VIServer -Server $vCenter -Credential (Get-Credential)

# Pronađi sve ugašene VM-ove
$poweredOffVMs = Get-VM | Where-Object { $_.PowerState -eq "PoweredOff" }

$result = foreach ($vm in $poweredOffVMs) {
    # Pronađi poslednji "powered off" event za VM
    $lastPowerOff = Get-VIEvent -Entity $vm -MaxSamples 1000 | 
        Where-Object { $_.FullFormattedMessage -like "*powered off*" } | 
        Sort-Object CreatedTime -Descending | Select-Object -First 1
    
    if ($lastPowerOff) {
        $daysOff = (New-TimeSpan -Start $lastPowerOff.CreatedTime -End (Get-Date)).Days
        
        [PSCustomObject]@{
            VMName = $vm.Name
            PowerState = $vm.PowerState
            PoweredOffDate = $lastPowerOff.CreatedTime
            DaysPoweredOff = $daysOff
            Host = $vm.VMHost.Name
        }
    }
}

# Prikaz rezultata sortirano po danima (najduže ugašene prve)
$result | Sort-Object DaysPoweredOff -Descending | Format-Table -AutoSize

# Opcionalno: sačuvaj u CSV
# $result | Export-Csv "UgaseneVMovi.csv" -NoTypeInformation -Encoding UTF8

Disconnect-VIServer * -Confirm:$false
