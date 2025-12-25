# Povezivanje na VMware vCenter ili ESXi host
Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password Beograd011

# Ime hosta sa kojeg želite generisati support bundle log
$hostName = "hoprodwin2esxi1"

# Definišite putanju za čuvanje support bundle loga
$outputPath = "C:\Temp\" 

# Generišite support bundle log
Get-VMHost $hostName | Get-Log -Bundle -DestinationPath $outputPath

# Odspajanje sa vCenter serverom ili ESXi hostom
Disconnect-VIServer -Server *
