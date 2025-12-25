# Povezivanje na vCenter Server
Connect-VIServer -Server hovcenter.rbj.co.yu

$credential = Get-Credential

# Naziv Datastore-a koji želite da promenite
$datastoreName = "hoesxi-citrix-00.53"

# Pronalaženje Datastore-a
$datastore = Get-Datastore -Name $datastoreName

if ($datastore) {
    # Prikaz trenutne postavke Multipath Policy (opciono)
    Write-Host "Trenutni Multipath Policy za $datastoreName: $($datastore.ExtensionData.Info.MultipathInfo.Policy)"

    # Postavljanje nove vrednosti za Multipath Policy ako je trenutna postavka VMW_PSP_FIXED
    $newPSP = "VMW_PSP_RR"
    if ($datastore.ExtensionData.Info.MultipathInfo.Policy -eq "VMW_PSP_FIXED") {
        $spec = New-Object VMware.Vim.HostMultipathInfoLogicalUnitPolicy
        $spec.policy = $newPSP
        $datastore.ExtensionData.UpdateMultipathPolicy($spec)
        
        # Potvrda promene
        Write-Host "Multipath Policy za $datastoreName uspešno promenjen na $newPSP"
    } else {
        Write-Host "Multipath Policy za $datastoreName već nije postavljen na VMW_PSP_FIXED"
    }
} else {
    Write-Host "Datastore $datastoreName nije pronađen."
}

# Odjava sa vCenter Servera
Disconnect-VIServer -Confirm:$false
