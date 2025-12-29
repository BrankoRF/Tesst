# Kreiranje log fajla
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "C:\temp\Brocade_Zone_Create_$timestamp.log"
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
Write-Log "Brocade Zone Create Script" -Level Info
Write-Log "Log fajl: $logFile" -Level Info
Write-Log "========================================" -Level Info

# Parametri za povezivanje
$switchIP = "192.168.1.10"  # PROMENI OVO
$user = "admin"  # PROMENI OVO
$password = "password"  # PROMENI OVO
$mlinkPath = "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe"  # Putanja do MobaXterm

# Ime konfiguracije
$cfgName = "zoneconfig"  # Ime konfiguracije sa Brocade switch-a

# Definisanje zona koje treba kreirati
# Svaka zona ima ime i članove (aliase ili WWN-ove odvojene sa ; )
$zonesToCreate = @(
    @{
        Name = "hoprodesxi1_31bG700_5E"
        Members = "hoprodesxi1_31b;G700_5E"  # Aliasi ili WWN-ovi odvojeni sa ;
    },
    @{
        Name = "zone_name_2"
        Members = "alias1;alias2;alias3"
    },
    @{
        Name = "zone_name_3"
        Members = "50:06:01:61:3E:E0:4B:00;50:06:01:69:3E:E0:4B:01"  # Direktno WWN-ovi
    }
)  # PROMENI OVO - dodaj sve zone koje želiš da kreiraš

Write-Log "========================================" -Level Info
Write-Log "Kreiranje zona na Brocade switch-u" -Level Info
Write-Log "Switch: $switchIP" -Level Info
Write-Log "Konfiguracija: $cfgName" -Level Info
Write-Log "Zone za kreiranje: $($zonesToCreate.Count)" -Level Info
Write-Log "========================================" -Level Info

# Kreiraj komande za sve zone
$commands = @()

# Dodaj zonecreate komande za svaku zonu
foreach ($zone in $zonesToCreate) {
    $zoneName = $zone.Name
    $zoneMembers = $zone.Members
    
    Write-Log "Priprema kreiranja zone: $zoneName sa članovima: $zoneMembers" -Level Warning
    $commands += "zonecreate `"$zoneName`", `"$zoneMembers`""
}

# Dodaj zone u konfiguraciju
foreach ($zone in $zonesToCreate) {
    $zoneName = $zone.Name
    Write-Log "Dodavanje zone '$zoneName' u konfiguraciju '$cfgName'" -Level Info
    $commands += "cfgadd `"$cfgName`", `"$zoneName`""
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
echo $password | & $mlinkPath -ssh $user@$switchIP $remoteCommand

Write-Log "`n========================================" -Level Success
Write-Log "Završeno kreiranje zona." -Level Success
Write-Log "========================================" -Level Success
Write-Log "Log fajl sačuvan: $logFile" -Level Info
