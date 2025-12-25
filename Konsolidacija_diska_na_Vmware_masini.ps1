# Poveži se na vCenter server
$vcenterServer = "hovcenter.rbj.co.yu"
$credential = Get-Credential
Connect-VIServer -Server $vcenterServer -Credential $credential

# Naziv virtualne mašine za koju želite da uradite konsolidaciju diska
$vmName = "ebanksqlrestore"

# Dobijanje VM objekta
$vm = Get-VM -Name $vmName

# Provera da li je potrebna konsolidacija diska
if ($vm.ExtensionData.Runtime.ConsolidationNeeded) {
    Write-Host "Disk consolidation needed for $vmName. Starting consolidation..."
    # Početak konsolidacije diska
    $task = $vm.ExtensionData.ConsolidateVMDisks_Task()
    $task | Wait-Task
    Write-Host "Disk consolidation completed for $vmName."
} else {
    Write-Host "Disk consolidation is not needed for $vmName."
}

# Odjava sa vCenter servera
Disconnect-VIServer -Server $vcenterServer -Confirm:$false