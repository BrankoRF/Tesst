# Import the VMware PowerCLI module
Import-Module VMware.PowerCLI

# Connect to the vCenter server
$vCenterServer = "hovcenter.rbj.co.yu"

$credential = Get-Credential

Connect-VIServer -Server $vCenterServer -Credential $credential

# Check connection status
if ($global:DefaultVIServer.IsConnected) {
    Write-Output "Connected to vCenter server '$vCenterServer'."
} else {
    Write-Output "Failed to connect to vCenter server '$vCenterServer'."
    exit
}

# Specify the VM name
$vmName = "ebanksqlrestore"

# Get the VM object
$vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue

if ($vm) {
    Write-Output "VM '$vmName' found."

    # Get the VM's snapshots
    $snapshots = Get-Snapshot -VM $vm -ErrorAction SilentlyContinue

    if ($snapshots) {
        Write-Output "VM '$vmName' has snapshots."

        # Check if consolidation is needed
        $vmView = Get-View -Id $vm.Id
        if ($vmView.Runtime.ConsolidationNeeded) {
            Write-Output "VM '$($vm.Name)' requires disk consolidation."
        } else {
            Write-Output "VM '$($vm.Name)' does not require disk consolidation."
        }
    } else {
        Write-Output "VM '$vmName' has no snapshots."
    }
} else {
    Write-Output "VM '$vmName' not found."
}

# Disconnect from the vCenter server
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
