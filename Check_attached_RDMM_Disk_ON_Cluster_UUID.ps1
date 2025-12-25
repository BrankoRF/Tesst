import-Module VMware.PowerCLI
 
# Poveži se na vCenter server
$vCenterServer = "hovcenter.rbj.co.yu"
 
$credential = Get-Credential
 
Connect-VIServer -Server $vCenterServer -Credential $credential
 
# Definiši ime klastera
$clusterName = "HO-Prod-Win-2"
 
# Dobavi klaster
$cluster = Get-Cluster -Name $clusterName
# $hostname="drdwhesxi1.rbj.co.yu"
# Dobavi sve virtualne mašine u klasteru
#$vms = Get-VM -Location $cluster
$vms = Get-VM -Location $hostname
 
# Proveri RDM diskove na svakoj VM i prikaži sve relevantne podatke
foreach ($vm in $vms) {
    Write-Host "Proveravam VM: $($vm.Name)"
    $hardDisks = Get-HardDisk -VM $vm
    foreach ($disk in $hardDisks) {
        if ($disk.ExtensionData.Backing.GetType().Name -eq "VirtualDiskRawDiskMappingVer1BackingInfo") {
            # Ukloni prvih 10 i zadnjih 12 karaktera iz LUN UUID-a, ostavljajući 32 karaktera
            $lunUuid = $disk.ExtensionData.Backing.LunUuid
            $cleanedLunUuid = $lunUuid.Substring(10, 32) # Uzmi 32 karaktera počevši od 10. karaktera
 
            $rdmDiskInfo = @{
                VMName = $vm.Name
                DiskName = $disk.Name
                CapacityGB = $disk.CapacityGB
                DeviceName = $disk.ExtensionData.DeviceName
                CompatibilityMode = $disk.ExtensionData.Backing.CompatibilityMode
                LunUuid = $cleanedLunUuid
            }
            $rdmDiskInfo | Format-Table -AutoSize
        }
    }
}
 
# Prekini konekciju sa vCenter serverom
Disconnect-VIServer -Server $vCenterServer -Confirm:$false