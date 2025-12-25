# Povezivanje sa VMware vCenter serverom
Connect-VIServer -Server drvcenter.rbj.co.yu -User yuasubr -Password S@lakazu22azu22

# Unesite ime virtuelne mašine čiju lokaciju želite pronaći
$vmNameToFind = "drfactoweb"

# Pronađite virtuelnu mašinu po imenu
$vm = Get-VM -Name $vmNameToFind

if ($vm -eq $null) {
    Write-Host "Virtuelna mašina '$vmNameToFind' nije pronađena."
} else {
    # Dohvatite putanju do foldera na Datastore-ima
    $datastorePath = $vm.ExtensionData.Config.Files.VmPathName

    Write-Host "Lokacija foldera za virtuelnu mašinu '$vmNameToFind':"
    Write-Host $datastorePath
}

# Odspojite se sa VMware vCenter serverom
Disconnect-VIServer -Server * -Confirm:$false