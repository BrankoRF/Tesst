Import-Module VMware.PowerCLI

# Kreiranje log fajla
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "C:\temp\Unmount_Datastores_$timestamp.log"
if (-not (Test-Path "C:\temp")) {
    New-Item -Path "C:\temp" -ItemType Directory -Force | Out-Null
}

# Logging funkcija
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Upiši u log fajl
    Add-Content -Path $logFile -Value $logMessage
    
    # Prikaz u konzoli sa bojama
    switch ($Level) {
        "Info"    { Write-Host $Message -ForegroundColor Cyan }
        "Success" { Write-Host $Message -ForegroundColor Green }
        "Warning" { Write-Host $Message -ForegroundColor Yellow }
        "Error"   { Write-Host $Message -ForegroundColor Red }
    }
}

Write-Log "========================================" -Level Info
Write-Log "Pokretanje skripte za unmount datastore-ova" -Level Info
Write-Log "Log fajl: $logFile" -Level Info
Write-Log "========================================" -Level Info

# Hardkodovani ESXi host i datastore imena (promeni prema potrebi)
$vmHost = "esxi01.domain.com"  # PROMENI OVO
$datastoreNames = @("Datastore1", "Datastore2", "Datastore3")  # PROMENI OVO (lista datastore-ova)

Write-Log "ESXi Host: $vmHost" -Level Info
Write-Log "Datastore-ovi: $($datastoreNames -join ', ')" -Level Info
Write-Log "Unesi kredencijale za ESXi host:" -Level Info
$credential = Get-Credential

# Poveži se direktno na ESXi host
try {
    Write-Log "Povezivanje na ESXi host '$vmHost'..." -Level Info
    Connect-VIServer -Server $vmHost -Credential $credential -ErrorAction Stop
    Write-Log "Uspešno povezan na ESXi host '$vmHost'" -Level Success
}
catch {
    Write-Log "Greška pri povezivanju na ESXi host: $_" -Level Error
    exit
}

# Proveri da li host postoji
$esxiHost = Get-VMHost -Name $vmHost -ErrorAction SilentlyContinue
if (-not $esxiHost) {
    Write-Log "Host '$vmHost' nije pronađen!" -Level Error
    Disconnect-VIServer -Server $vmHost -Confirm:$false
    exit
}

# Procesiraj svaki datastore pojedinačno
foreach ($datastoreName in $datastoreNames) {
    Write-Log "`n========================================" -Level Info
    Write-Log "Procesuiranje datastore-a: '$datastoreName'" -Level Info
    Write-Log "========================================" -Level Info
    
    $datastore = Get-Datastore -Name $datastoreName -ErrorAction SilentlyContinue
    
    if (-not $datastore) {
        Write-Log "Datastore '$datastoreName' nije pronađen! Preskačem..." -Level Error
        continue
    }
    
    # Proveri da li ima VM-ova na tom datastore-u za ovaj host
    $vmsOnDatastore = Get-VM -Datastore $datastore | Where-Object { $_.VMHost.Name -eq $vmHost }
    if ($vmsOnDatastore) {
        Write-Log "UPOZORENJE: Postoje VM-ovi na datastore-u '$datastoreName' na host-u '$vmHost':" -Level Warning
        $vmsOnDatastore | Select-Object Name, PowerState | Format-Table -AutoSize
        $confirm = Read-Host "Da li želiš da nastaviš sa unmount za '$datastoreName'? (Da/Ne)"
        if ($confirm -ne "Da") {
            Write-Log "Unmount za '$datastoreName' otkazan. Nastavljam sa sledećim..." -Level Warning
            continue
        }
    }
    
    # Unmount datastore sa hosta koristeći View API
    try {
        Write-Log "Unmounting datastore '$datastoreName' sa hosta '$vmHost'..." -Level Info
        
        # Dobavi datastore View objekat i UUID
        $datastoreView = $datastore | Get-View
        $datastoreUuid = $datastoreView.Info.Vmfs.Uuid
        
        # Dobavi host storage system
        $hostView = $esxiHost | Get-View
        $storageSystem = Get-View $hostView.ConfigManager.StorageSystem
        
        # Unmount VMFS volume
        $storageSystem.UnmountVmfsVolume($datastoreUuid)
        
        Write-Log "Datastore '$datastoreName' uspešno unmount-ovan sa hosta '$vmHost'." -Level Success
    }
    catch {
        Write-Log "Greška prilikom unmount-a datastore-a '$datastoreName': $_" -Level Error
    }
}

Write-Log "`n========================================" -Level Success
Write-Log "Završeno procesiranje svih datastore-ova." -Level Success
Write-Log "========================================" -Level Success
Write-Log "Log fajl sačuvan: $logFile" -Level Info

# Diskonektuj se sa ESXi hosta
Disconnect-VIServer -Server $vmHost -Confirm:$false
