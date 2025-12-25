# Povezivanje na VMware vCenter
Connect-VIServer -Server drvcenter.rbj.co.yu -User yuasubr -Password 21S@lakazu21azu


# Naziv virtualne port grupe (Virtual Port Group) za koju želite postaviti sigurnosne politike
$portGroupName = "VLAN72"

# Naziv ESXi host servera na kojem se nalazi odabrana port grupa
$hostServerName = "drpharmwfa13.rbj.co.yu"

# Pronalaženje odabrane port grupe na host serveru
$portGroup = Get-VirtualPortGroup -Name $portGroupName -VMHost $hostServerName

# Postavljanje sigurnosnih politika za odabranu port grupu
Set-SecurityPolicy $portGroup -AllowPromiscuous $true -ForgedTransmits $true -MacChanges $true

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
