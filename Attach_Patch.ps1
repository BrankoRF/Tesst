# Povezivanje na VMware vCenter server
Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password S@lakazu22azu22
#Connect-VIServer -Server drvcenter.rbj.co.yu -User yuasubr -Password S@lakazu22azu22

# Naziv hosta na koji želite dodati nadogradnju
$hostName = "hoprodwin2esxi5.rbj.co.yu"


# Naziv baselina patcha koji želite da prikačite
$baselineName = "ESXi-7.0U3o-22348816"

# Dobijanje host objekta
$targetHost = Get-VMHost -Name $hostName

# Dobijanje baseline objekta
$baseline = Get-Baseline -Name $baselineName

if ($targetHost -ne $null -and $baseline -ne $null) {
    # Prikazivanje informacija o operaciji
    Write-Host "Prikacivanje baseline patcha '$($baseline.Name)' na host '$($targetHost.Name)'"
    
    # Prikacivanje baseline-a na host
    Attach-Baseline -Entity $targetHost -Baseline $baseline -Confirm:$false
} else {
    Write-Host "Host ili baseline nisu pronađeni."
}

# Odspajanje sa VMware vCenter serverom
Disconnect-VIServer -Server * -Confirm:$false