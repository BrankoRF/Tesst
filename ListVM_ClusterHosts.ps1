# Povezivanje na VMware vCenter
# Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password 21S@lakazu21azu

Connect-VIServer -Server hovcenter.rbj.co.yu
$credential = Get-Credential

# Ime datoteke za zapis rezultata
$outputFile = "C:\Temp\vm_host_clusters.txt"

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
        $vmName = $vm.Name
        $vmHost = $vm.VMHost.Name
        $vmDatastore = $vm.Datastore.Name
        $vmSizeGB = [math]::Round(($vm.ExtensionData.Summary.Storage.Committed + $vm.ExtensionData.Summary.Storage.Uncommitted) / 1GB, 2)

        WriteToOutputFile "  VM: $vmName, Host Cluster: $hostCluster, Host Server: $vmHost, Datastore: $vmDatastore, Size: ${vmSizeGB}GB"
    }
}

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
