# Učitaj PowerCLI modul ako nije već učitan
if (-not (Get-Module -Name VMware.PowerCLI)) {
    Import-Module VMware.PowerCLI -ErrorAction Stop
}

# Parametri: vCenter, host, i mrežni testovi
$vCenterServer = "drvcenter.rbj.co.yu"
$esxiHostName = "drprodesxi10.rbj.co.yu"

# Lista IP adresa i portova koje testiramo (kao hashtable; IP => portova lista)
$testTargets = @{
  "10.233.250.243" = @(31031, 32032)
}

# Dohvati kredencijale od korisnika
$cred = Get-Credential -Message "Unesite korisničko ime i lozinku za povezivanje na vCenter $vCenterServer"

# Povezivanje na vCenter koristeći unete kredencijale
Connect-VIServer -Server $vCenterServer -Credential $cred -ErrorAction Stop

# Dohvati host
$host = Get-VMHost -Name $esxiHostName

if (-not $host) {
    Write-Error "Host $esxiHostName nije pronađen na vCenteru"
    Disconnect-VIServer -Server $vCenterServer -Confirm:$false
    exit
}

# Funkcija za proveru porta (TCP connect test)
function Test-Port {
    param(
        [string]$ip,
        [int]$port,
        [int]$timeoutMs = 2000
    )
    try {
        $sock = New-Object System.Net.Sockets.TcpClient
        $iar = $sock.BeginConnect($ip, $port, $null, $null)
        $success = $iar.AsyncWaitHandle.WaitOne($timeoutMs, $false)
        if (-not $success) {
            return $false
        }
        $sock.EndConnect($iar)
        $sock.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Izvrši test za svaki IP i port
foreach ($ip in $testTargets.Keys) {
    foreach ($port in $testTargets[$ip]) {
        Write-Host "Testiram konekciju sa hosta $esxiHostName ka ${ip}:${port} ..."
        $status = Test-Port -ip $ip -port $port
        if ($status) {
            Write-Host "Port $port na $ip je OTVOREN" -ForegroundColor Green
        }
        else {
            Write-Host "Port $port na $ip je ZATVOREN ili NEDOSTUPAN" -ForegroundColor Red
        }
    }
}

# Isključi konekciju
Disconnect-VIServer -Server $vCenterServer -Confirm:$false