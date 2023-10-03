# Povezivanje na VMware vCenter
Connect-VIServer -Server ime vcentra -User username -Password pass
Connect-VIServer -Server ive vcentra -User username -Password pass

# Ime datoteke za zapis rezultata
$outputFilePath = "C:\Temp\vm_disk_sizes.csv"

# Funkcija za zapisivanje linije u datoteku
function WriteToOutputFile($line, $filePath) {
    $line | Out-File -Append -FilePath $filePath
}

# Popis svih VM-ova, ukoliko se izbrise linija -Name i masine skripta ce raditi na svim masinama upit za proveru velicine diskova
$virtualMachines = Get-VM -Name "virtualmaina ime1, virtualmasina ime2"

# Stvaranje praznog niza za spremanje rezultata
$results = @()

# Prolazak kroz sve virtualne mašine
foreach ($vm in $virtualMachines) {
    $vmName = $vm.Name

    # Popis diskova na virtualnoj mašini
    $disks = $vm | Get-HardDisk

    foreach ($disk in $disks) {
        $diskName = $disk.Name
        $diskSizeGB = [math]::Round($disk.CapacityGB, 2)

        # Stvaranje objekta sa podacima
        $resultObject = [PSCustomObject]@{
            "VirtualMachine" = $vmName
            "DiskName" = $diskName
            "DiskSizeGB" = $diskSizeGB
        }

        # Dodavanje objekta u niz rezultata
        $results += $resultObject
    }
}

# Izvoz rezultata u CSV datoteku
$results | Export-Csv -Path $outputFilePath -NoTypeInformation

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
