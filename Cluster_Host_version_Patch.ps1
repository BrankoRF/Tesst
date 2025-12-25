# Povezivanje na VMware vCenter
#Connect-VIServer -Server drvcenter.rbj.co.yu 
#Connect-VIServer -Server hovcenter.rbj.co.yu
Connect-VIServer -Server "ucsvcenter.bankmeridian.com"
$credential = Get-Credential

# Dobijanje liste svih klastera
$clusters = Get-Cluster

# Inicijalizacija praznog niza za hostove
$hostsData = @()

foreach ($cluster in $clusters) {
    $clusterName = $cluster.Name

    # Dobijanje svih hostova u klasteru
    $clusterHosts = Get-Cluster $cluster | Get-VMHost

    foreach ($clusterHost in $clusterHosts) { # Promenjeno ime promenljive
        $esxiVersion = $clusterHost.Version
        $patchVersion = $clusterHost.ExtensionData.Config.Product.Build

        $hostData = New-Object PSObject -Property @{
            "Cluster" = $clusterName
            "HostName" = $clusterHost.Name  # Promenjeno ime promenljive
            "Version" = $esxiVersion
            "PatchVersion" = $patchVersion  # Dodata verzija patcha
        }
        $hostsData += $hostData
    }
}


# Export podataka o hostovima u CSV fajl
$exportPath = "C:\Temp\Sloba_Cluster_Host_version_Patch.csv"
$hostsData | Export-Csv -Path $exportPath -NoTypeInformation

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false

Write-Host "Podaci o hostovima su izvezeni u $exportPath."