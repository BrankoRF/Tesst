# Povezivanje na VMware vCenter
Connect-VIServer -Server drvcenter.rbj.co.yu -User username -Password pass

# Naziv ESXi host servera na kojem želite izlistati port grupe
$hostServerName = "drpharmwfa11.rbj.co.yu"

# Pronalaženje odabranog host servera
$hostServer = Get-VMHost -Name $hostServerName

# Izlistavanje imena port grupa na host serveru
$portGroups = Get-VirtualPortGroup -VMHost $hostServer | Select-Object -ExpandProperty Name

# Prikazivanje imena port grupa
$portGroups

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
