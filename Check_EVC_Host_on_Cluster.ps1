# Povezivanje na vCenter server
Connect-VIServer -Server "hovcenter.rbj.co.yu"
$credential = Get-Credential

# Dobijanje informacija o VM hostovima unutar određenog klastera
$clusterName = "HO-Test-Win"
Get-Cluster -Name $clusterName | Get-VMHost | Select-Object Name, ProcessorType, MaxEVCMode

# Odlazak sa vCenter servera
Disconnect-VIServer -Confirm:$false