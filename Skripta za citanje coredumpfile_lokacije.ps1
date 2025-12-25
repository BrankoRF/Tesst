 Connect-VIServer -Server hovcenter.rbj.co.yu -User yuasubr -Password Beograd011
 Write-Host "`nCore Dump Settings:`r" -ForegroundColor Green

$clusterName = "HO-Citrix"
$cluster = Get-Cluster -Name $clusterName
$hosts = Get-Cluster $cluster | Get-VMHost | Sort-Object Name

foreach ($vmhost in $hosts) {
  $esxcli2 = Get-EsxCli -VMHost $vmhost -V2
  $coreDumpInfo = $esxcli2.system.coredump.file.get.Invoke()
  Write-Host "Host Name: $($vmhost.Name)"
  Write-Host "Active Core Dump File: $($coreDumpInfo.Active)"
}

Clear-Variable vmhost, esxcli2 -Scope Global