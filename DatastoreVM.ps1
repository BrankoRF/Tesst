# Povezivanje na VMware vCenter
Connect-VIServer -Server hovcenter.rbj.co.yu -User username -Password password

# Ime datoteke za zapis rezultata
$outputFile = "C:\Temp\DatastoreVM.txt"

# Funkcija za zapisivanje linije u datoteku
function WriteToOutputFile($line) {
    $line | Out-File -Append -FilePath $outputFile
}

# Popis svih klastera
$clusters = Get-Cluster

# Prolazak kroz svaki klaster
foreach ($cluster in $clusters) {
    WriteToOutputFile "Cluster: $($cluster.Name)"

    # Popis svih datastore-ova koji pripadaju klasteru
    $clusterDatastores = $cluster | Get-Datastore

    foreach ($datastore in $clusterDatastores) {
        WriteToOutputFile "  Datastore: $($datastore.Name)"

        # Popis svih VM na datastore-u
        $vmsOnDatastore = $datastore | Get-VM

        # Prolazak kroz svaku VM na datastore-u
        foreach ($vm in $vmsOnDatastore) {
            if ($vm.Guest.OSFullName) {
                WriteToOutputFile "    VM: $($vm.Name), OS: $($vm.Guest.OSFullName)"
            }
        }
    }
}

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
