#Login to vcenter
$vcenter = "drvcenter.rbj.co.yu"

#Select Cluster
#$cluster_name = "HO-Citrix"

Connect-VIServer $vcenter
$credential = Get-Credential

# Function to get ESXi Patch Version for a given host
function Get-HostPatchVersion {
    param(
        [string]$HostName
    )

    $hostInfo = Get-VMHost -Name $HostName
    if ($hostInfo) {
        $esxVersion = $hostInfo.Version
        $esxBuild = $hostInfo.Build

        if ($esxVersion -match '^(\d+\.\d+\.\d+)') {
            $esxVersion = $matches[1]
        }
        else {
            $esxVersion = ""
        }

        $cpuUsage = Get-Stat -Entity $HostName -Stat cpu.usage.average -MaxSamples 1 | Select-Object -ExpandProperty Value
        $memoryUsage = Get-Stat -Entity $HostName -Stat mem.usage.average -MaxSamples 1 | Select-Object -ExpandProperty Value

        $datastore = Get-Datastore -VMHost $HostName | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1
        $datastoreCapacity = $datastore.CapacityGB
        $datastoreFreeSpace = $datastore.FreeSpaceGB
        $storageUsage = ($datastoreCapacity - $datastoreFreeSpace) / $datastoreCapacity * 100

        return @{
            HostName = $HostName
            'ESX Version' = $esxVersion
            'ESX Build' = $esxBuild
            'CPU Usage (%)' = $cpuUsage
            'Memory Usage (%)' = $memoryUsage
            'Storage Usage (%)' = $storageUsage
        }
    }
    else {
        Write-Warning "Host '$HostName' not found."
    }
}

# Create an array to store the results
$results = @()

# Get all hosts and add to results
$allHosts = Get-VMHost
$totalHosts = $allHosts.Count
$counter = 0

foreach ($vmhost in $allHosts) {
    $counter++
    $percentComplete = ($counter / $totalHosts) * 100
    $progressStatus = "Processing Host $($vmhost.Name)"
    Write-Progress -Activity "Retrieving ESXi Patch Versions" -Status $progressStatus -PercentComplete $percentComplete

    $result = Get-HostPatchVersion -HostName $vmhost.Name
    if ($result) {
        $results += New-Object PSObject -Property $result
    }
}

# Display the results on the console
$results | Format-Table

# Export the results to a CSV file
$results | Select-Object HostName, 'ESX Version', 'ESX Build', 'CPU Usage (%)', 'Memory Usage (%)', 'Storage Usage (%)' | Export-Csv -Path "C:\Users\yuasubr\Documents\PowershellScript\Report\DR_Strana_File.csv" -NoTypeInformation

# Complete the progress bar
Write-Progress -Activity "Retrieving ESXi Patch Versions" -Status "Complete" -Completed
