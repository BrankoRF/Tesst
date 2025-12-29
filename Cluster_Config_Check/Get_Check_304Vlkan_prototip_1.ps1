# Učitavanje VMware PowerCLI modula i konekcija na vCenter
Import-Module VMware.PowerCLI
Connect-VIServer -Server "hovcenter.rbj.co.yu" -User "username" -Password "pass"

# Definisanje VLAN ID koji tražimo
$targetVLAN = 304

# Definisanje izuzetaka - liste imena mašina i cluster imena koje ćemo ignorisati
$vmExclusions = @("hogitlab", "hoteamcity", "sbtremote", "cistestws")
$clusterExclusions = @("HO-Remote")

# Dohvatanje svih klastera osim izuzetih
$clusters = Get-Cluster | Where-Object { $clusterExclusions -notcontains $_.Name }

foreach ($cluster in $clusters) {
    # Dohvatanje svih VM-ova u clusteru osim izuzetih
    $vms = Get-VM -Location $cluster | Where-Object { $vmExclusions -notcontains $_.Name }

    foreach ($vm in $vms) {
        # Provera da li VM ima mrežni adapter sa VLAN 304
        $networkAdapters = Get-NetworkAdapter -VM $vm
        $foundVLAN = $false

        foreach ($adapter in $networkAdapters) {
            $portGroup = Get-VirtualPortGroup -VM $vm | Where-Object { $_.Name -eq $adapter.NetworkName }
            if ($null -ne $portGroup -and $portGroup.VlanId -eq $targetVLAN) {
                $foundVLAN = $true
                break
            }
        }

        # Ako je VLAN pronađen, ispiši samo ime VM i ime clustera
        if ($foundVLAN) {
            Write-Host "VM: $($vm.Name), Cluster: $($cluster.Name)"
        }
    }
}

# Diskonektovanje sa vCenter
Disconnect-VIServer -Confirm:$false
