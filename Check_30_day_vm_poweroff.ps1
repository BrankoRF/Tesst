# Učitaj VMware PowerCLI modul ako već nije učitan
# Import-Module VMware.PowerCLI

# Podesi ime vCenter servera
$vCenter = "hovcenter.rbj.co.yu"

# Traži kredencijale od korisnika
#$cred = Get-Credential

# Konekcija na vCenter uz Get-Credential promenljivu
Connect-VIServer -Server $vCenter -Credential (Get-Credential)

# Prag od koliko dana je VM ugašena
$days = 30
$thresholdDate = (Get-Date).AddDays(-$days)

# Uzmemo sve VM koje su trenutno PoweredOff
$poweredOffVMs = Get-VM | Where-Object { $_.PowerState -eq "PoweredOff" }

# Uzmemo evente vezane za ove VM od praga do danas
$events = Get-VIEvent -Entity $poweredOffVMs -Start $thresholdDate -MaxSamples ([int]::MaxValue) |
    Where-Object { $_.FullFormattedMessage -like "*is powered off*" }

# Pronađemo poslednji powered-off event po VM
$lastPowerOffByVM = @{}
foreach ($ev in $events) {
    $vmName = $ev.Vm.Name
    if (-not $lastPowerOffByVM.ContainsKey($vmName)) {
        $lastPowerOffByVM[$vmName] = $ev.CreatedTime
    } elseif ($lastPowerOffByVM[$vmName] -lt $ev.CreatedTime) {
        $lastPowerOffByVM[$vmName] = $ev.CreatedTime
    }
}

# Izračunamo koliko je dana svaka VM ugašena i filtriramo one sa >= 30 dana
$result = foreach ($vm in $poweredOffVMs) {
    if ($lastPowerOffByVM.ContainsKey($vm.Name)) {
        $poDate = $lastPowerOffByVM[$vm.Name]
        $daysOff = (New-TimeSpan -Start $poDate -End (Get-Date)).Days
        if ($daysOff -ge $days) {
            [PSCustomObject]@{
                VMName          = $vm.Name
                PowerState      = $vm.PowerState
                PoweredOffDate  = $poDate
                DaysPoweredOff  = $daysOff
                VMHost          = $vm.VMHost
                Cluster         = $vm.VMHost.Parent.Name
            }
        }
    }
}

# Prikaz rezultata
$result | Sort-Object DaysPoweredOff -Descending | Format-Table -AutoSize

# Po želji, eksport u CSV
# $result | Export-Csv -NoTypeInformation -Path "C:\Temp\PoweredOffVMs_30days.csv"

# Diskonektovanje sa vCenter‑a
Disconnect-VIServer * -Confirm:$false
