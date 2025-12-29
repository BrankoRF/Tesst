# Kreiranje log fajla
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "C:\temp\Brocade_Zone_Delete_$timestamp.log"
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
Write-Log "Brocade Zone Delete Script" -Level Info
Write-Log "Log fajl: $logFile" -Level Info
Write-Log "========================================" -Level Info

# Parametri za povezivanje
$switchIP = "192.168.1.10"  # PROMENI OVO
$user = "admin"  # PROMENI OVO
$password = "password"  # PROMENI OVO
$mlinkPath = "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe"  # Putanja do MobaXterm

# Ime konfiguracije
$cfgName = "zoneconfig"  # Ime konfiguracije sa Brocade switch-a

# Lista zona koje treba obrisati (dodaj više zona ovde)
$zoneNames = @(
    "hoprodesxi1_31bG700_5E",
    "zone_name_2",
    "zone_name_3"
)  # PROMENI OVO - dodaj sve zone koje želiš da obrišeš

Write-Log "========================================" -Level Info
Write-Log "Brisanje zona sa Brocade switch-a" -Level Info
Write-Log "Switch: $switchIP" -Level Info
Write-Log "Konfiguracija: $cfgName" -Level Info
Write-Log "Zone za brisanje: $($zoneNames.Count)" -Level Info
Write-Log "========================================" -Level Info

# Kreiraj komande za sve zone
$commands = @()

# Dodaj cfgremove komande za svaku zonu
foreach ($zoneName in $zoneNames) {
    Write-Log "Priprema brisanja zone: $zoneName" -Level Warning
    $commands += "cfgremove `"$cfgName`", `"$zoneName`""
}

# Dodaj zonedelete komande za svaku zonu
foreach ($zoneName in $zoneNames) {
    $commands += "zonedelete `"$zoneName`""
}

# Sačuvaj konfiguraciju
$commands += "cfgsave"
$commands += "y"  # Potvrda za cfgsave

# Aktiviraj konfiguraciju
Write-Log "Dodavanje cfgenable komande..." -Level Info
$commands += "cfgenable `"$cfgName`""
$commands += "y"  # Potvrda za cfgenable

Write-Log "`nIzvršavanje komandi..." -Level Info

# Izvršavanje preko SSH
$remoteCommand = $commands -join "`n"
echo $password | & "$mlinkPath" -ssh "$user@$switchIP" $remoteCommand

Write-Log "`n========================================" -Level Success
Write-Log "Završeno brisanje zona." -Level Success
Write-Log "========================================" -Level Success
Write-Log "Log fajl sačuvan: $logFile" -Level Info
