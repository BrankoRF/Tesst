# Povezivanje na VMware vCenter
Connect-VIServer -Server imevcentra -User username -Password pass
# Ime datoteke za zapis rezultata
$outputFilePath = "C:\Temp\vm_host_clusters.csv"

# Popis svih klastera
$clusters = Get-Cluster

# Stvaranje praznog niza za spremanje rezultata
$results = @()

# Prolazak kroz sve klastera
foreach ($cluster in $clusters) {
    $clusterName = $cluster.Name

    # Popis svih VM unutar klastera
    $vmsInCluster = $cluster | Get-VM

    foreach ($vm in $vmsInCluster) {
        $vmName = $vm.Name
        $hostCluster = ($vm.VMHost | Get-Cluster).Name
        $hostName = $vm.VMHost.Name

        # Popis svih datastore-ova na hostu
        $datastores = $vm.VMHost | Get-Datastore

        # Popis VLAN-ova na hostu
        $vlans = $vm.VMHost | Get-VirtualPortGroup

        # Stvaranje objekta sa podacima
        $resultObject = [PSCustomObject]@{
            "Cluster" = $clusterName
            "VM" = $vmName
            "HostCluster" = $hostCluster
            "HostName" = $hostName
            "Datastores" = ($datastores | ForEach-Object { $_.Name }) -join ', '
            "VLANs" = ($vlans | ForEach-Object { "VLAN: $($_.VlanId), Ime: $($_.Name)" }) -join ', '
        }

        # Dodavanje objekta u niz rezultata
        $results += $resultObject
    }
}

# Izvoz rezultata u CSV datoteku
$results | Export-Csv -Path $outputFilePath -NoTypeInformation

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
