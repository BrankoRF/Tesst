# Kreiranje log fajla
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = "C:\temp\Brocade_Alias_Delete_$timestamp.log"
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
Write-Log "Brocade Alias Delete Script" -Level Info
Write-Log "Log fajl: $logFile" -Level Info
Write-Log "========================================" -Level Info

# Parametri za povezivanje
$switchIP = "192.168.1.10"  # PROMENI OVO
$user = "admin"  # PROMENI OVO
$password = "password"  # PROMENI OVO
$mlinkPath = "C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe"  # Putanja do MobaXterm

# Ime konfiguracije
$cfgName = "zoneconfig"  # Ime konfiguracije sa Brocade switch-a

# Lista aliasa koje treba obrisati (dodaj više aliasa ovde)
$aliasNames = @(
    "alias_name_1",
    "alias_name_2",
    "alias_name_3"
)  # PROMENI OVO - dodaj sve aliase koje želiš da obrišeš

Write-Log "========================================" -Level Info
Write-Log "Brisanje aliasa sa Brocade switch-a" -Level Info
Write-Log "Switch: $switchIP" -Level Info
Write-Log "Konfiguracija: $cfgName" -Level Info
Write-Log "Aliasi za brisanje: $($aliasNames.Count)" -Level Info
Write-Log "========================================" -Level Info

# Kreiraj komande za sve aliase
$commands = @()

# Dodaj alidelete komande za svaki alias
foreach ($aliasName in $aliasNames) {
    Write-Log "Priprema brisanja aliasa: $aliasName" -Level Warning
    $commands += "alidelete `"$aliasName`""
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
Write-Log "Završeno brisanje aliasa." -Level Success
Write-Log "========================================" -Level Success
Write-Log "Log fajl sačuvan: $logFile" -Level Info
