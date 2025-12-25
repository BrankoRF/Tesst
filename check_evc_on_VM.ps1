# Povezivanje na vCenter server
Connect-VIServer -Server "hovcenter.rbj.co.yu"

$credential = Get-Credential

# Specifična virtuelna mašina
$vmName = "assecoremote7"

# Dobijanje informacija o određenoj virtuelnoj mašini
Get-VM -Name $vmName | Select-Object Name, HardwareVersion,
    @{Name='VM_EVC_Mode';Expression={$_.ExtensionData.Runtime.MinRequiredEVCModeKey}},
    @{Name='Cluster_Name';Expression={$_.VMHost.Parent.Name}},
    @{Name='Cluster_EVC_Mode';Expression={$_.VMHost.Parent.EVCMode}} | Format-Table -AutoSize

# Odlazak sa vCenter servera
Disconnect-VIServer -Confirm:$false