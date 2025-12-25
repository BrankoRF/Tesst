# Povezivanje sa VMware vCenter serverom
Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password S@lakazu22azu22

# Definišite putanju za čuvanje rezultata u TXT fajlu
$outputFilePath = "C:\Temp\G600_G200_VM_host.txt"

# Pronalaženje svih Datastore-ova sa nazivima koji sadrže "G600" ili "G200"
$datastores = Get-Datastore | Where-Object { $_.Name -like "*G600*" -or $_.Name -like "*G200*" }

# Otvorite TXT fajl za pisanje
$outputFile = New-Item -Path $outputFilePath -ItemType File -Force

foreach ($datastore in $datastores) {
    Add-Content -Path $outputFile -Value "Datastore: $($datastore.Name)"
    
    # Pronalaženje virtualnih mašina na Datastore-u
    $vmsOnDatastore = Get-Datastore -Id $datastore.Id | Get-VM

    if ($vmsOnDatastore.Count -eq 0) {
        Add-Content -Path $outputFile -Value "  - Nema virtualnih mašina na ovom Datastore-u"
    } else {
        Add-Content -Path $outputFile -Value "  - Virtualne Mašine:"
        foreach ($vm in $vmsOnDatastore) {
            $vmHosts = Get-VMHost -VM $vm | Select-Object -ExpandProperty Name
            $vmHostsStr = $vmHosts -join ", "
            Add-Content -Path $outputFile -Value "    - $($vm.Name) (Hostovi: $vmHostsStr)"
        }
    }
    
    Add-Content -Path $outputFile -Value ""
}

# Zatvorite TXT fajl kada završite
$outputFile.Close()

# Odspajanje sa VMware vCenter serverom
Disconnect-VIServer -Server * -Confirm:$false






