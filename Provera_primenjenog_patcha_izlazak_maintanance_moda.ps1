# Postavite parametre za vCenter konekciju
#$vCenterServer = "ImeVCenterServera"
#$vCenterUsername = "KorisnickoIme"
#$vCenterPassword = "Lozinka"

# Povežite se na vCenter
Connect-VIServer -Server drvcenter.rbj.co.yu
$credential = Get-Credential

# Postavite putanju do log fajla
$logFilePath = "C:\Temp\LogFajl_proverapacha.txt"

# Funkcija za zapisivanje poruke u log fajl
function Write-Log ($message) {
    $logMessage = "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - $message"
    $logMessage | Out-File -Append -FilePath $logFilePath
}

# Postavite parametre za host i baseline
$hostName = "drdwhesxi1.rbj.co.yu"
$baselineName = "ESXi-7.0U3o-22348816"

# Dobijte host objekat
$targetHost = Get-VMHost -Name $hostName

# Dobijte baseline objekat
$baseline = Get-Baseline -Name $baselineName

if ($targetHost -ne $null -and $baseline -ne $null) {
    # Proverite da li je baseline primenjen na hostu
    $baselineCompliance = Get-BaselineCompliance -Entity $targetHost -Baseline $baseline

    if ($baselineCompliance.ComplianceStatus -eq "NonCompliant") {
        # Baseline nije primenjen, prikažite upozorenje
        $warningMessage = "Upozorenje: Baseline '$baselineName' nije primenjen na hostu '$hostName'. Host ne može izaći iz maintenance moda."
        Write-Host $warningMessage
        Write-Log $warningMessage
    } else {
        # Baseline je primenjen, host može izaći iz maintenance moda
        $successMessage = "Baseline '$baselineName' je primenjen na hostu '$hostName'. Izlazak iz maintenance moda."
        Write-Host $successMessage
        Write-Log $successMessage

        # Komanda za izlazak iz maintenance moda
        $targetHost | Set-VMHost -State Connected

        $exitMessage = "Host '$hostName' je izašao iz maintenance moda."
        Write-Host $exitMessage
        Write-Log $exitMessage
    }
} else {
    $errorMessage = "Upozorenje: Host ili baseline nisu pronađeni."
    Write-Host $errorMessage
    Write-Log $errorMessage
}

# Odspojite se sa vCenter
Disconnect-VIServer -Server $vCenterServer -Force -Confirm:$false