# Povezivanje na vCenter Server
Connect-VIServer -Server <vCenterServer>

$credential = Get-Credential

# Dohvatanje svih Datastore-ova na kojima želite promeniti Multipath Policy
$datastores = Get-Datastore

# Postavljanje nove vrednosti za Multipath Policy
$newPSP = "VMW_PSP_RR"

foreach ($datastore in $datastores) {
    # Prikaz trenutnih postavki Multipath Policy za svaki Datastore (opciono)
    Write-Host "Datastore: $($datastore.Name), Current PSP: $($datastore.ExtensionData.Info.MultipathInfo.Policy)"
    
    # Promena Multipath Policy samo ako je trenutna postavka VMW_PSP_FIXED
    if ($datastore.ExtensionData.Info.MultipathInfo.Policy -eq "VMW_PSP_FIXED") {
        $spec = New-Object VMware.Vim.HostMultipathInfoLogicalUnitPolicy
        $spec.policy = $newPSP
        $datastore.ExtensionData.UpdateMultipathPolicy($spec)
        
        # Potvrda promene
        Write-Host "Multipath Policy za $($datastore.Name) uspešno promenjen na $newPSP"
    } else {
        Write-Host "Multipath Policy za $($datastore.Name) već nije postavljen na VMW_PSP_FIXED"
    }
}

# Odjava sa vCenter Servera
Disconnect-VIServer -Confirm:$false