<#
Skripta:
- Na nivou celog vCenter-a pronalazi VM-ove sa povezanim CD/ISO (Connected, StartConnected ili IsoPath postavljen).
- Idempotentno i bezbedno raskida CD (Connected:false, StartConnected:false) i uklanja ISO (NoMedia).
- Izveštaj sa listama VM-ova (u jednom redu, razdvojeno razmakom).

Parametri:
- -VCenter "vc.example.local"  (opciono: povezuje se na vCenter ako već nisi povezan)
- -Datacenters @("DC1","DC2")   (opciono: ograničenje na datacentre)
- -Clusters @("ClusterA")       (opciono: ograničenje na klastere)
- -VmExclusions @("vm1","vm2")  (opciono: izuzmi VM-ove po imenu)
- -WhatIf                       (probni rad bez izmene)

Napomene:
- Set-CDDrive -NoMedia uklanja ISO backing (IsoPath) i sprečava SRM/migracione probleme.
- Skripta je idempotentna: bezbedno može da se pokreće više puta.
#>

param(
    [string]$VCenter = "",
    [string[]]$Datacenters = @(),
    [string[]]$Clusters = @(),
    [string[]]$VmExclusions = @(),
    [switch]$WhatIf
)

# Opciona konekcija na vCenter
if ($VCenter -and -not (Get-VIServer -ErrorAction SilentlyContinue)) {
    Connect-VIServer -Server $VCenter | Out-Null
}

# Priprema skupa VM-ova (union lokacija)
$locations = @()
if ($Datacenters.Count -gt 0) {
    $locations += (Get-Datacenter | Where-Object { $Datacenters -contains $_.Name })
}
if ($Clusters.Count -gt 0) {
    $locations += (Get-Cluster | Where-Object { $Clusters -contains $_.Name })
}
$locations = $locations | Sort-Object -Unique

$allVms = if ($locations.Count -gt 0) { Get-VM -Location $locations } else { Get-VM }
if ($VmExclusions.Count -gt 0) {
    $allVms = $allVms | Where-Object { $VmExclusions -notcontains $_.Name }
}

# Rezultati
$changedVMs   = New-Object System.Collections.Generic.List[string]
$unchangedVMs = New-Object System.Collections.Generic.List[string]
$errors       = New-Object System.Collections.Generic.List[string]

# Glavna obrada
foreach ($vm in $allVms) {
    try {
        $cds = Get-CDDrive -VM $vm -ErrorAction Stop
        if (-not $cds) {
            $unchangedVMs.Add($vm.Name)
            continue
        }

        $didChange = $false
        foreach ($cd in $cds) {
            $isoSet = -not [string]::IsNullOrWhiteSpace($cd.IsoPath)
            $connected = $cd.ConnectionState.Connected
            $startConnected = $cd.StartConnected

            if ($isoSet -or $connected -or $startConnected) {
                # Idempotentno: uvek postavi na bezbedno stanje (NoMedia + isključen connect)
                Set-CDDrive -CDDrive $cd -Connected:$false -StartConnected:$false -NoMedia -Confirm:$false -WhatIf:$WhatIf
                $didChange = $true
            }
        }

        if ($didChange) {
            $changedVMs.Add($vm.Name)
        } else {
            $unchangedVMs.Add($vm.Name)
        }
    }
    catch {
        $errors.Add("$($vm.Name): $($_.Exception.Message)")
    }
}

# Kratak rezime
Write-Output ("Skenirano: {0}  Izmenjeno: {1}  Bez promene: {2}  Greške: {3}" -f $allVms.Count, $changedVMs.Count, $unchangedVMs.Count, $errors.Count)

# Ispis listi u jednom redu (razdvojeno razmakom)
if ($changedVMs.Count -gt 0) {
    Write-Output ("Izmenjeni VM-ovi: " + ([string]::Join(' ', ($changedVMs | Sort-Object -Unique))))
}
if ($unchangedVMs.Count -gt 0) {
    Write-Output ("Neizmenjeni VM-ovi: " + ([string]::Join(' ', ($unchangedVMs | Sort-Object -Unique))))
}
if ($errors.Count -gt 0) {
    Write-Output ("Greške: " + ([string]::Join(' ', $errors)))
}

# Po želji: zatvori sesiju
# Disconnect-VIServer -Confirm:$false
