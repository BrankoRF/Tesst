# Povezivanje na VMware vCenter
Connect-VIServer -Server <vCenterServer> -User <username> -Password <password>

# Ime datoteke za zapis rezultata
$outputFile = "vm_host_clusters.txt"

# Funkcija za zapisivanje linije u datoteku
function WriteToOutputFile($line) {
    $line | Out-File -Append -FilePath $outputFile
}

# Popis svih klastera
$clusters = Get-Cluster

foreach ($cluster in $clusters) {
    WriteToOutputFile "Cluster: $($cluster.Name)"

    # Popis svih VM unutar klastera
    $vmsInCluster = $cluster | Get-VM

    foreach ($vm in $vmsInCluster) {
        $hostCluster = ($vm.VMHost | Get-Cluster).Name
        WriteToOutputFile "  VM: $($vm.Name), Host Cluster: $hostCluster"
    }
}

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
