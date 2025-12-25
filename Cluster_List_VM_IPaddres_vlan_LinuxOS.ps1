# Povezivanje sa VMware vCenter serverom ili ESXi hostom
Connect-VIServer -Server drvcenter.rbj.co.yu

$credential = Get-Credential

# Naziv VMware clustera
$clusterName = "DR-Prod"

# Dobijanje informacija o virtualnim mašinama unutar određenog clustera
$cluster = Get-Cluster -Name $clusterName
$vmInfo = Get-VM -Location $cluster | ForEach-Object {
    $vm = $_
    $guestInfo = Get-VMGuest -VM $vm
    $networkInfo = Get-VirtualPortGroup -VM $vm | Where-Object { $_.Name -ne "VM Network" }
    if ($guestInfo) {
        $os = $guestInfo.OSFullName
    } else {
        $os = "N/A"
    }
    if ($os -like "*Linux*") {
        [PSCustomObject]@{
            Name = $vm.Name
            IPAddress = ($vm | Get-VMGuest).IPAddress
            VLAN = if ($networkInfo) { $networkInfo.VlanId } else { "N/A" }
        }
    }
}

# Prikazivanje informacija o imenima virtualnih mašina (samo Linux), IP adresama i VLAN-ovima
$vmInfo | Format-Table -AutoSize

# Putanja do TXT fajla
$txtFilePath = "C:\Temp\DR-Prod_Linux_VirtualnimMasinama.txt"

# Pisanje rezultata u TXT fajl
$vmInfo | Format-Table -AutoSize | Out-File -FilePath $txtFilePath

# Odspajanje sa vCenter serverom ili ESXi hostom
Disconnect-VIServer -Confirm:$false
