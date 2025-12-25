# Učitavanje VMware PowerCLI modula i konekcija na vCenter
Import-Module VMware.PowerCLI
Connect-VIServer -Server "hovcenter.rbj.co.yu" -User "admsubr" -Password "011Beograd"

# Definisanje VLAN ID koji tražimo
$targetVLAN = 304

# Definisanje izuzetaka - liste imena mašina i cluster imena koje ćemo ignorisati
$vmExclusions = @("hogitlab", "hoteamcity", "sbtremote", "cistestws")
$clusterExclusions = @("Ho-remote")

# Dohvatanje svih klastera osim izuzetih
$clusters = Get-Cluster | Where-Object { $clusterExclusions -notcontains $_.Name }

foreach ($cluster in $clusters) {
    Write-Host "Provera VLAN-$targetVLAN u clusteru $($cluster.Name)"
    # Dohvatanje svih VM-ova u clusteru osim izuzetih
    $vms = Get-VM -Location $cluster | Where-Object { $vmExclusions -notcontains $_.Name }

    foreach ($vm in $vms) {
        # Dohvatanje svih mrežnih adaptera za VM i proveravanje VLAN-a
        $networkAdapters = Get-NetworkAdapter -VM $vm

        $foundVLAN = $false
        foreach ($adapter in $networkAdapters) {
            # Dobijanje VLAN ID-a sa adaptera
            # Za standardni port group, VLAN ID može biti dobijen iz portgroup settings
            $portGroup = Get-VirtualPortGroup -VM $vm | Where-Object { $_.Name -eq $adapter.NetworkName }
            if ($null -ne $portGroup) {
                if ($portGroup.VlanId -eq $targetVLAN) {
                    $foundVLAN = $true
                    break
                }
            }
        }

        if ($foundVLAN) {
            Write-Host "VM $($vm.Name) ima VLAN u clusteru $($cluster.Name)"
        }
    }
}

# Disconnect sa vCenter kada se završi
Disconnect-VIServer -Confirm:$false
