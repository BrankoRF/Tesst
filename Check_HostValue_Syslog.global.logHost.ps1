# Postavljanje povezivanja sa VMware vCenter serverom
Connect-VIServer -Server drvcenter.rbj.co.yu

$credential = Get-Credential

# Putanja do izlaznog fajla
$outputFilePath = "C:\Temp\Syslog.global.logHost.txt"

# Dobijanje liste svih klastera
$clusters = Get-Cluster

# Pisanje rezultata u izlazni fajl
$results = @()

# Provera svakog klastera
foreach ($cluster in $clusters) {
    $clusterResult = "Provera klastera: $($cluster.Name)"
    Write-Host $clusterResult
    $results += $clusterResult

    # Dobijanje liste svih hostova u klasteru
    $hostsInCluster = Get-VMHost -Location $cluster

    # Provera svakog hosta u klasteru
    foreach ($hostInCluster in $hostsInCluster) {
        # Dobijanje vrednosti za Syslog.global.logHost iz Advanced system settings
        $logHost = Get-AdvancedSetting -Entity $hostInCluster -Name "Syslog.global.logHost" -ErrorAction SilentlyContinue

        if ($logHost -eq $null) {
            $hostResult = "Na hostu $($hostInCluster.Name) u klasteru $($cluster.Name) nije postavljena vrednost za Syslog.global.logHost."
            Write-Host $hostResult
            $results += $hostResult
        } else {
            $hostResult = "Na hostu $($hostInCluster.Name) u klasteru $($cluster.Name) postavljena je vrednost za Syslog.global.logHost: $($logHost.Value)"
            Write-Host $hostResult
            $results += $hostResult
        }
    }
}

# Pisanje rezultata u izlazni fajl
$results | Out-File -FilePath $outputFilePath

# Odjava iz vCenter servera
Disconnect-VIServer -Confirm:$false