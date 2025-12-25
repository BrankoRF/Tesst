# Connect to vCenter Server
$server = "hovcenter.rbj.co.yu"
$credential = Get-Credential
Connect-VIServer -Server $server -Credential $credential

# Specify the folder name
$folderName = "DMS"

# Find the folder
$folder = Get-Folder -Name $folderName

# Get all VMs in the folder
$vms = Get-VM -Location $folder

# Iterate through each VM and get its datastore information
foreach ($vm in $vms) {
    $datastores = Get-Datastore -RelatedObject $vm
    foreach ($datastore in $datastores) {
        $datastoreSizeTB = [math]::round($datastore.CapacityMB / 1024 / 1024, 2) # Convert MB to TB
        Write-Output "VM Name: $($vm.Name)"
        Write-Output "Datastore Name: $($datastore.Name)"
        Write-Output "Datastore Size: $datastoreSizeTB TB"
        Write-Output "-----------------------------"
    }
}

# Disconnect from vCenter Server
Disconnect-VIServer -Server $server -Confirm:$false
