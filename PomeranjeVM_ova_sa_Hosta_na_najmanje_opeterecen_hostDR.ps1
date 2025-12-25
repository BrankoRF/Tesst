# Povezivanje na VMware vCenter
Connect-VIServer -Server ucsvcenter.bankmeridian.com -User suznjevic1 -Password S@lakazu23azu23
#Connect-VIServer -Server drvcenter.rbj.co.yu -User yuasubr -Password S@lakazu22azu22

# Definisanje imena klastera i hosta sa kojeg želite pomeriti virtualne mašine
$sourceClusterName = "CA_DELL_cluster"
#$sourceClusterName = "DR-Citrix" 
$sourceHostName = "caesxinode10.bankmeridian.com"

# Putanja do log fajla
$logFilePath = "C:\temp\caesxinode8.rbj.co.yu_log_fajl.txt"

# Otvaranje log fajla za pisanje
$logFile = New-Object System.IO.StreamWriter($logFilePath, $true)

# Dobijanje klastera i hosta izvora
$sourceCluster = Get-Cluster -Name $sourceClusterName
$sourceHost = Get-VMHost -Name $sourceHostName

# Dobijanje svih virtualnih mašina na izvoru
$sourceVMs = $sourceHost | Get-VM

# Dobijanje svih hostova u klasteru
$destinationHosts = Get-VMHost -Location $sourceCluster

# Prolazak kroz sve virtualne mašine na izvoru i odabir hosta sa najmanjim zauzećem resursa
foreach ($vm in $sourceVMs) {
    $vmName = $vm.Name

    # Dobijanje trenutnog zauzeća resursa (CPU i memorija) za virtualnu mašinu
    $cpuUsage = $vm.ExtensionData.Summary.QuickStats.OverallCpuUsage
    $memUsage = $vm.ExtensionData.Summary.QuickStats.HostMemoryUsage

    $bestDestinationHost = $null
    $lowestResourceUsage = [double]::MaxValue

    # Pronalaženje hosta sa najmanjim zauzećem resursa
    foreach ($destinationHost in $destinationHosts) {
        $destinationHostResourceUsage = $destinationHost.ExtensionData.Summary.QuickStats.OverallCpuUsage + $destinationHost.ExtensionData.Summary.QuickStats.HostMemoryUsage

        if ($destinationHostResourceUsage -lt $lowestResourceUsage) {
            $bestDestinationHost = $destinationHost
            $lowestResourceUsage = $destinationHostResourceUsage
        }
    }

    # Pomeranje virtualne mašine na najbolji host
    Move-VM -VM $vm -Destination $bestDestinationHost -Confirm:$false

    # Upisivanje informacija u log fajl
    $logEntry = "Virtualna mašina $vmName je pomerena sa hosta $sourceHostName na host $bestDestinationHost.Name."
    $logFile.WriteLine($logEntry)
    Write-Host $logEntry
}

# Zatvaranje log fajla
$logFile.Close()

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false

Write-Host "Sve virtualne mašine su pomerene i informacije su zabeležene u $logFilePath."