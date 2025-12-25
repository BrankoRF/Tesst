# Povezivanje na VMware vCenter
Connect-VIServer -Server hovcenter.rbj.co.yu -User username -Password pass
Connect-VIServer -Server drvcenter.rbj.co.yu -User username -Password pass

# Ime datoteke za zapis rezultata
$outputFilePath = "C:\Temp\vm_disk_sizes.csv"

# Funkcija za zapisivanje linije u datoteku
function WriteToOutputFile($line, $filePath) {
    $line | Out-File -Append -FilePath $filePath
}

# Popis svih VM-ova, ukoliko se izbrise linija -Name i masine skripta ce raditi na svim masinama upit za proveru velicine diskova
$virtualMachines = Get-VM -Name "HOEBPPDF","HOEBPAPP1","PDREP","HOEBPWEB1","HOEBANKWEBSTAT","HOEBPWREPORTING","HOEBANKIN2ROL","HOEBPWEB2","HOEBPADMIN","EBPP2PDF","EBWEBTEST2","EBTAPP1","EBTADMIN","EBPP2APP2","EBTPDF","IBANKRELAY","EBPP2SQL","EBPP2APP1","EBPP2ADMIN","HOROLPKI","DREBPWEB1","DREBPAPP1","EBTWEB1","DRCMS","HOEBPAPP2","EBPP2WEB2","EBPP2WEB1","DREBPAPP2","DREBPWEB2","HOEBPAPP3","HOEBPWEB3","HOEBPWEB5","HOEBPWEB6","HOEBPAPP5","HOEBPAPP6","HOEBPADMIN2","EBTADMIN2","HOEBPAPP4","ebanktsql","HOEBPWEB4","EBPP2APP3","EBPP2WEB3","EBTPDF2","EBINTEGADMIN","EBINTEGADMIN2","EBINTEGPDF","EBINTEGWEB1","EBINTEGAPP1","EBINTEGIN2ROL","ebankppsql","ebanksqlrestore","hoebankreport","hoebnode1","hoebnode2","drebnsql","ebankpp19sql"

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
