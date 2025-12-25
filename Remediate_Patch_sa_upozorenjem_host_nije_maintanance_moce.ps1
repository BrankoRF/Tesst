# Povezivanje sa VMware vCenter serverom
#Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password S@lakazu22azu22
Connect-VIServer -Server drvcenter.rbj.co.yu

$credential = Get-Credential

# Naziv hosta na kojem želite da izvršite remedijaciju
$hostName = "drpharmwfa13.rbj.co.yu"

# Naziv baselina patcha koji želite da primenite
$baselineName = "ESXi-7.0U3o-22348816"

# Dobijanje host objekta
$targetHost = Get-VMHost -Name $hostName

# Dobijanje baseline objekta
$baseline = Get-Baseline -Name $baselineName

if ($targetHost -ne $null -and $baseline -ne $null) {
    # Provera da li je host u režimu održavanja
    if ($targetHost.ConnectionState -ne "Maintenance") {
        Write-Host "Upozorenje: Host '$($targetHost.Name)' nije u režimu održavanja."
        Write-Host "Akcija remedijacije je prekinuta."
    } else {
        # Prikazivanje informacija o operaciji
        Write-Host "Izvršavanje remedijacije hosta '$($targetHost.Name)' sa baseline patchom '$($baseline.Name)'"
    
        # Remedijacija hosta sa određenim patchem
        Remediate-Inventory -Entity $targetHost -Baseline $baseline -Confirm:$false
    }
} else {
    Write-Host "Host ili baseline nisu pronađeni."
}

# Odspajanje sa VMware vCenter serverom
Disconnect-VIServer -Server * -Confirm:$false
