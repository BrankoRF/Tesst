# Učitaj PowerCLI modul
Import-Module VMware.PowerCLI -Force

# Parametri za mail
$smtpServer = "hurricane.raiffeisenbank.rs"   # promeni
$mailFrom   = "hovcentert@rbj.co.yu"
$mailTo     = "branko.suznjevic@raiifaisenbank.rs"
$mailSubj   = "Izveštaj – ugašene VM mašine"

# Konekcija na vCenter
$cred = -User "nagios@vsphere.local" -Password "beograd011"
$vCenter = "drvcenter.rbj.co.yu"  # Promeni ovo
Connect-VIServer -Server $vCenter -Credential $cred

# Pronađi sve ugašene VM-ove
$poweredOffVMs = Get-VM | Where-Object { $_.PowerState -eq "PoweredOff" }

$result = foreach ($vm in $poweredOffVMs) {
    $lastPowerOff = Get-VIEvent -Entity $vm -MaxSamples 1000 |
        Where-Object { $_.FullFormattedMessage -like "*powered off*" } |
        Sort-Object CreatedTime -Descending | Select-Object -First 1
    
    if ($lastPowerOff) {
        $daysOff = (New-TimeSpan -Start $lastPowerOff.CreatedTime -End (Get-Date)).Days
        
        [PSCustomObject]@{
            VMName          = $vm.Name
            PowerState      = $vm.PowerState
            PoweredOffDate  = $lastPowerOff.CreatedTime
            DaysPoweredOff  = $daysOff
            Host            = $vm.VMHost.Name
        }
    }
}

# Sortiraj rezultat
$result = $result | Sort-Object DaysPoweredOff -Descending

# Prikaz u konzoli
$result | Format-Table -AutoSize

# (Opcionalno) Sačuvaj u CSV
 $datum = Get-Date -Format "yyyyMMdd"
 $csvPath = "C:\Temp\UgaseneVMoviDrvcenter_$datum.csv"
 $result | Export-Csv $csvPath -NoTypeInformation -Encoding UTF8

# Priprema HTML tela maila
if ($result -and $result.Count -gt 0) {
    $htmlBody = $result | ConvertTo-Html -Property VMName,PowerState,PoweredOffDate,DaysPoweredOff,Host `
        -Title "Ugašene VM mašine_$datum" `
        | Out-String
} else {
    $htmlBody = "<html><body><p>Nema ugašenih VM mašina koje zadovoljavaju kriterijum.</p></body></html>"
}

# Slanje maila sa HTML tabelom u telu
Send-MailMessage `
    -From $mailFrom `
    -To $mailTo `
    -Subject $mailSubj `
    -Body $htmlBody `
    -BodyAsHtml `
    -SmtpServer $smtpServer

Disconnect-VIServer * -Confirm:$false