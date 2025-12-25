# Povezivanje sa VMware vCenter serverom ili ESXi hostom
Connect-VIServer -Server hovcenter.rbj.co.yu

$credential = Get-Credential

# Naziv VMware clustera
$clusterName = "HO-DMZ1"

# Dobijanje informacija o virtualnim mašinama unutar određenog clustera
$cluster = Get-Cluster -Name $clusterName
$vmInfo = Get-VM -Location $cluster | Select-Object Name, @{Name='IPAddress';Expression={(Get-VMGuest -VM $_).IPAddress}}, @{Name='VLAN';Expression={(Get-VirtualPortGroup -VM $_ | Where-Object {$_.Name -ne "VM Network"}).VlanId}}

# Prikazivanje informacija o imenima virtualnih mašina, IP adresama i VLAN-ovima
$vmInfo | Format-Table -AutoSize

# Putanja do TXT fajla
$txtFilePath = "C:\Temp\HO-DMZ1_VirtualnimMasinama.txt"

# Pisanje rezultata u TXT fajl
$vmInfo | Format-Table -AutoSize | Out-File -FilePath $txtFilePath

# Odspajanje sa vCenter serverom ili ESXi hostom
Disconnect-VIServer -Confirm:$false
