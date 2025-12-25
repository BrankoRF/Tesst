# Povezivanje sa VMware vCenter serverom ili ESXi hostom
Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password 21S@lakazu21azu
Connect-VIServer -Server drvcenter.rbj.co.yu -User yuasubr -Password 21S@lakazu21azu

# Naziv virtuelne mašine čije informacije želite da dobijete
$vmName = "DRFSHARE"

# Dobijanje virtuelne mašine
$vm = Get-VM -Name $vmName

# Dobijanje informacija o virtuelnim diskovima na VM
$diskInfo = $vm | Get-HardDisk | Select-Object -Property Name, CapacityGB, FileName, Type, StorageFormat, VirtualDeviceNode

# Prikazivanje informacija o svakom virtuelnom disku
$diskInfo | Format-Table -AutoSize

# Odspajanje sa vCenter serverom ili ESXi hostom
Disconnect-VIServer -Confirm:$false
