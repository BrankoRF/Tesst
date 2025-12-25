# Povezivanje sa VMware vCenter serverom
Connect-VIServer -Server hovcenter.rbj.co.yu

$credential = Get-Credential

# Unesite naziv clustera
$clusterName = "HO-Prod-Lin"

# Definišite putanju za čuvanje rezultata u TXT fajlu
$outputFilePath = "C:\Temp\HO-Prod-Lin_VM_datastore_size_04.01.txt"

# Pronalaženje clustera
$cluster = Get-Cluster -Name $clusterName

# Otvorite TXT fajl za pisanje
$outputFile = New-Item -Path $outputFilePath -ItemType File -Force

# Prikazivanje svih hostova u clustera
$vmhosts = $cluster | Get-VMHost

foreach ($vmhost in $vmhosts) {
    Add-Content -Path $outputFile -Value "Host: $($vmhost.Name)"
    
    # Prikazivanje virtualnih mašina na hostu
    $vmsOnHost = $vmhost | Get-VM

    foreach ($vm in $vmsOnHost) {
        Add-Content -Path $outputFile -Value "  - Virtual Machine: $($vm.Name)"
        
        # Prikazivanje Datastore-ova povezanih sa virtualnom mašinom i njihove veličine
        $datastores = $vm | Get-Datastore

        foreach ($datastore in $datastores) {
            $datastoreName = $datastore.Name
            $datastoreSizeGB = [math]::Round($datastore.CapacityGB, 2)
            Add-Content -Path $outputFile -Value "    - Datastore: $datastoreName (Veličina: $datastoreSizeGB GB)"
        }
    }
    
    Add-Content -Path $outputFile -Value ""
}

# Zatvorite TXT fajl kada završite
$outputFile.Close()

# Odspajanje sa VMware vCenter serverom