# Povezivanje na VMware vCenter
Connect-VIServer -Server drvcenter.rbj.co.yu -User username -Password pass

# Naziv ESXi host servera na kojem želite izlistati virtualne switcheve
$hostServerName = "drpharmwfa11.rbj.co.yu"

# Pronalaženje odabranog host servera
$hostServer = Get-VMHost -Name $hostServerName

# Izlistavanje imena virtualnih switch-eva na host serveru
$virtualSwitches = Get-VirtualSwitch -VMHost $hostServer | Select-Object -ExpandProperty Name

# Prikazivanje imena virtualnih switch-eva
$virtualSwitches

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
