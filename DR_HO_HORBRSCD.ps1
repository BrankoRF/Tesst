# Povezivanje na vCenter Server - DR
$ho = Connect-VIServer -Server drvcenter.rbj.co.yu -User admsubr  -Password 011Beograd
# Povezivanje na vCenter Server - HO
$dr = Connect-VIServer -Server hovcenter.rbj.co.yu -User admsubr  -Password 011Beograd


# VM koja se migrira
$vm = Get-VM -Server $ho -Name HORBRSCD

# Nova lokacija na drugom vCentru - DR -> HO
 $novaLokacija = @{
   Server = $dr
   Datastore = Get-Datastore -Server $dr -Name hoprod-win-E1090-01.03
   Destination = Get-VMHost -Server $dr -Name hoprodwin2esxi3.rbj.co.yu
   InventoryLocation = Get-Folder -Server $dr -Type VM -Name "Domain Unit servers"
   PortGroup = Get-VMHost -Server $dr -Name hoprodwin2esxi1.rbj.co.yu | Get-VirtualPortGroup -Server $dr -Name VLAN858
 } 


# Provera destinacije
$novaLokacija

# Migracija same mašine
$vm | Move-VM @novaLokacija

# Odjava sa vCenter Servera - HO
Disconnect-VIServer -Server $ho -Confirm:$false

# Odjava sa vCenter Servera - DR
Disconnect-VIServer -Server $dr -Confirm:$false