# Povezivanje na vCenter Server
Connect-VIServer -Server hovcenter.rbj.co.yu

$credential = Get-Credential

# Ime Datastore Clustera koji želite istražiti
$datastoreClusterName = "HO-Prod-Lin-E1090"

# Dohvati Datastore Cluster objekat
$datastoreCluster = Get-DatastoreCluster -Name $datastoreClusterName

# Dohvati sve virtualne mašine u Datastore Clusteru
$virtualMachines = Get-VM -Location $datastoreCluster

# Putanja i ime izlaznog fajla
$outputFilePath = "C:\Temp\HO-Prod-Lin-E1090_Izvestaja.txt"

# Otvori ili kreira izlazni fajl
$outFile = New-Object System.IO.StreamWriter $outputFilePath

# Prikazi informacije o virtualnim mašinama i upiši u izlazni fajl
foreach ($vm in $virtualMachines) {
    $vmName = $vm.Name
    $vmSizeGB = [math]::Round(($vm.ExtensionData.Summary.Storage.Committed + $vm.ExtensionData.Summary.Storage.Uncommitted) / 1GB, 2)

    $outputLine = "Virtual Machine: $vmName, Size: ${vmSizeGB}GB"
    Write-Host $outputLine
    $outFile.WriteLine($outputLine)
}

# Zatvori izlazni fajl
$outFile.Close()

# Odjavi se s vCenter Servera
Disconnect-VIServer -Confirm:$false