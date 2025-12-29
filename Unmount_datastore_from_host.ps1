Import-Module VMware.PowerCLI

# Hardkodovani ESXi host i datastore (promeni prema potrebi)
$vmHost = "esxi01.domain.com"  # PROMENI OVO
$datastoreName = "DatastoreName"  # PROMENI OVO

Write-Host "ESXi Host: $vmHost" -ForegroundColor Cyan
Write-Host "Datastore: $datastoreName" -ForegroundColor Cyan
Write-Host "Unesi kredencijale za ESXi host:" -ForegroundColor Cyan
$credential = Get-Credential

# Poveži se direktno na ESXi host
try {
    Write-Host "Povezivanje na ESXi host '$vmHost'..." -ForegroundColor Cyan
    Connect-VIServer -Server $vmHost -Credential $credential -ErrorAction Stop
    Write-Host "Uspešno povezan na ESXi host '$vmHost'" -ForegroundColor Green
}
catch {
    Write-Host "Greška pri povezivanju na ESXi host: $_" -ForegroundColor Red
    exit
}

# Proveri da li postoje
$esxiHost = Get-VMHost -Name $vmHost -ErrorAction SilentlyContinue
$datastore = Get-Datastore -Name $datastoreName -ErrorAction SilentlyContinue

if (-not $esxiHost) {
    Write-Host "Host '$vmHost' nije pronađen!" -ForegroundColor Red
    Disconnect-VIServer -Server $vmHost -Confirm:$false
    exit
}

if (-not $datastore) {
    Write-Host "Datastore '$datastoreName' nije pronađen!" -ForegroundColor Red
    Disconnect-VIServer -Server $vmHost -Confirm:$false
    exit
}

# Proveri da li ima VM-ova na tom datastore-u za ovaj host
$vmsOnDatastore = Get-VM -Datastore $datastore | Where-Object { $_.VMHost.Name -eq $vmHost }
if ($vmsOnDatastore) {
    Write-Host "UPOZORENJE: Postoje VM-ovi na datastore-u '$datastoreName' na host-u '$vmHost':" -ForegroundColor Yellow
    $vmsOnDatastore | Select-Object Name, PowerState | Format-Table -AutoSize
    $confirm = Read-Host "Da li želiš da nastaviš sa unmount? (Da/Ne)"
    if ($confirm -ne "Da") {
        Write-Host "Unmount otkazan." -ForegroundColor Cyan
        Disconnect-VIServer -Server $vmHost -Confirm:$false
        exit
    }
}

# Unmount datastore sa hosta koristeći View API
try {
    Write-Host "Unmounting datastore '$datastoreName' sa hosta '$vmHost'..." -ForegroundColor Cyan
    
    # Dobavi datastore View objekat i UUID
    $datastoreView = $datastore | Get-View
    $datastoreUuid = $datastoreView.Info.Vmfs.Uuid
    
    # Dobavi host storage system
    $hostView = $esxiHost | Get-View
    $storageSystem = Get-View $hostView.ConfigManager.StorageSystem
    
    # Unmount VMFS volume
    $storageSystem.UnmountVmfsVolume($datastoreUuid)
    
    Write-Host "Datastore '$datastoreName' uspešno unmount-ovan sa hosta '$vmHost'." -ForegroundColor Green
}
catch {
    Write-Host "Greška prilikom unmount-a: $_" -ForegroundColor Red
}

# Diskonektuj se sa ESXi hosta
Disconnect-VIServer -Server $vmHost -Confirm:$false