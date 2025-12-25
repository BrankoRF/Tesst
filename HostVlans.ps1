# Povezivanje na VMware vCenter
Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password 21S@lakazu21azu

# Ime datoteke za zapis rezultata
$outputFile = "C:\Temp\host_vlans.txt"

# Funkcija za zapisivanje linije u datoteku
function WriteToOutputFile($line) {
    $line | Out-File -Append -FilePath $outputFile
}

# Popis svih hostova
$vmHosts = Get-VMHost

foreach ($vmHost in $vmHosts) {
    WriteToOutputFile "Host: $($vmHost.Name)"

    # Popis svih VLAN-ova na hostu
    $vlans = $vmHost | Get-VirtualPortGroup
    WriteToOutputFile "  Dostupni VLAN-ovi:"
    foreach ($vlan in $vlans) {
        WriteToOutputFile "    VLAN: $($vlan.VlanId), Ime: $($vlan.Name)"
    }
}

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false

