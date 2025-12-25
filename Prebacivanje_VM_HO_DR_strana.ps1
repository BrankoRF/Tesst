# Povezivanje na vCenter Server - HO
$ho = Connect-VIServer -Server hovcenter.rbj.co.yu -User admsubr  -Password unesi password
# Povezivanje na vCenter Server - DR
$dr = Connect-VIServer -Server drvcenter.rbj.co.yu -User admsubr  -Password unesi password

# VM koja se migrira
$vm = Get-VM -Server $ho -Name ime masine

# Nova lokacija na drugom vCentru - DR -> HO
 $novaLokacija = @{
   Server = $dr
   Datastore = Get-Datastore -Server $dr -Name dresxi-prod-KG370-05.54
   Destination = Get-VMHost -Server $dr -Name drprodesxi9.rbj.co.yu
   InventoryLocation = Get-Folder -Server $dr -Type VM -Name "Domain Unit servers"
   PortGroup = Get-VMHost -Server $dr -Name drprodesxi9.rbj.co.yu | Get-VirtualPortGroup -Server $dr -Name VLAN860
 } 


# Provera destinacije
$novaLokacija

# Migracija same mašine
$vm | Move-VM @novaLokacija

# Odjava sa vCenter Servera - HO
Disconnect-VIServer -Server $ho -Confirm:$false

# Odjava sa vCenter Servera - DR
Disconnect-VIServer -Server $dr -Confirm:$false