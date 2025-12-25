# Učitavanje VMware PowerCLI modula i konekcija na vCenter
Import-Module VMware.PowerCLI
Connect-VIServer -Server "hovcenter.rbj.co.yu" -User "username" -Password "pass"

$targetVLAN = 304
# Definisanje izuzetaka - liste imena mašina i cluster imena koje ćemo ignorisati
$vmExclusions = @("hogitlab", "hoteamcity", "sbtremote", "cistestws")
$clusterExclusions = @("HO-Remote")

$clusters = Get-Cluster | Where-Object { $clusterExclusions -notcontains $_.Name }

foreach ($cluster in $clusters) {
    $vms = Get-VM -Location $cluster | Where-Object { $vmExclusions -notcontains $_.Name }

    # Lista mašina za koje je pronađen VLAN u ovom clusteru
    $vmList = @()

    foreach ($vm in $vms) {
        $networkAdapters = Get-NetworkAdapter -VM $vm
        $foundVLAN = $false

        foreach ($adapter in $networkAdapters) {
            $portGroup = Get-VirtualPortGroup -VM $vm | Where-Object { $_.Name -eq $adapter.NetworkName }
            if ($null -ne $portGroup -and $portGroup.VlanId -eq $targetVLAN) {
                $foundVLAN = $true
                break
            }
        }

        if ($foundVLAN) {
            $vmList += $vm.Name
        }
    }

    if ($vmList.Count -gt 0) {
        Write-Host "Cluster: $($cluster.Name)"
        foreach ($vmName in $vmList) {
            Write-Host "  VM: $vmName"
        }
        Write-Host ""  # prazan red između cluster-a
    }
}

Disconnect-VIServer -Confirm:$false
