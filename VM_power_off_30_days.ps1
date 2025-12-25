# Povezivanje na vCenter Server ili ESXi host
$vCenterServer = "hovcenter.rbj.co.yu"
$vCenterUsername = "yuasubr"
$vCenterPassword = "19S@lakazu19azu"
Connect-VIServer -Server $vCenterServer -User $vCenterUsername -Password $vCenterPassword

# Dobijanje svih ESXi hostova
$hosts = Get-VMHost

# Definisanje maksimalnog doba za isključene virtualne mašine (u ovom slučaju 30 dana)
$maxDaysPoweredOff = 30

# Dobijanje isključenih virtualnih mašina koje su isključene duže od $maxDaysPoweredOff dana
$poweredOffVMs = $hosts | Get-VM | Where-Object { $_.PowerState -eq "PoweredOff" -and $_.Guest -eq $null -and ($_.ExtensionData.Runtime.BootTime -lt (Get-Date).AddDays(-$maxDaysPoweredOff)) }

# Prikazivanje informacija o isključenim virtualnim mašinama
Write-Host "Isključene virtualne mašine koje su isključene duže od $maxDaysPoweredOff dana:"
foreach ($vm in $poweredOffVMs) {
    $vmName = $vm.Name
    $lastPoweredOff = $vm.ExtensionData.Runtime.PowerStateChangeTime
    $daysSincePoweredOff = (Get-Date) - $lastPoweredOff

    Write-Host "Virtualna mašina: $vmName"
    Write-Host "Poslednje iskljucene pre: $daysSincePoweredOff dana"
    Write-Host "-----------------------------"
}

# Odjavljivanje sa vCenter Servera ili ESXi hosta
Disconnect-VIServer -Confirm:$false
