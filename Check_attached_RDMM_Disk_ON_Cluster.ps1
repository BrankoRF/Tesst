# Učitaj VMware PowerCLI module
Import-Module VMware.PowerCLI

# Poveži se na vCenter server
$vCenterServer = "hovcenter.rbj.co.yu"

$credential = Get-Credential
 
Connect-VIServer -Server $vCenterServer -Credential $credential

# Definiši ime klastera
$clusterName = "HO-Sticky"

# Dobavi klaster
$cluster = Get-Cluster -Name $clusterName

# Dobavi sve virtualne mašine u klasteru
$vms = Get-VM -Location $cluster

# Proveri RDM diskove na svakoj VM i prikaži sve relevantne podatke
foreach ($vm in $vms) {
    Write-Host "Proveravam VM: $($vm.Name)"
    $hardDisks = Get-HardDisk -VM $vm
    foreach ($disk in $hardDisks) {
        if ($disk.ExtensionData.Backing.GetType().Name -eq "VirtualDiskRawDiskMappingVer1BackingInfo") {
            $rdmDiskInfo = @{
                VMName = $vm.Name
                DiskName = $disk.Name
                CapacityGB = $disk.CapacityGB
                DeviceName = $disk.ExtensionData.DeviceName
                CompatibilityMode = $disk.ExtensionData.Backing.CompatibilityMode
                LunUuid = $disk.ExtensionData.Backing.LunUuid
            }
            $rdmDiskInfo | Format-Table -AutoSize
        }
    }
}

# Prekini konekciju sa vCenter serverom
Disconnect-VIServer -Server $vCenterServer -Confirm:$false