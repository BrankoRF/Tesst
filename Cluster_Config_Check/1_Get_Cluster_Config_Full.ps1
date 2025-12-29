# 1_Get_Cluster_Config_Full.ps1
[CmdletBinding()]
param(
    [string]$vCenter = "hovcenter.rbj.co.yu"
)

$ErrorActionPreference = 'Stop'

# Klaster(i) definisani kroz promenljivu
$clusters = @("HO-Prod-Win-2")

try {
    $cred = Get-Credential -Message "Unesite kredencijale za $vCenter"
    Connect-VIServer -Server $vCenter -Credential $cred | Out-Null

    $timestamp = Get-Date -Format "yyyy-MM-dd"
    $path = "C:\Users\yuasubr\Documents\PowershellScript\Cluster_Config_Check\$timestamp"
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    $outFile = Join-Path $path "Cluster_Config.csv"

    $clusterObjs = Get-Cluster -Name $clusters -ErrorAction SilentlyContinue
    if (-not $clusterObjs) {
        Write-Error "Nije pronaðen nijedan klaster po imenu: $($clusters -join ', ')"
        return
    }

    $results = New-Object System.Collections.Generic.List[object]

    foreach ($cluster in $clusterObjs) {
        $vmHosts = Get-VMHost -Location $cluster | Sort-Object Name
        if (-not $vmHosts) {
            Write-Warning "Klaster '$($cluster.Name)' nema hostova."
            continue
        }

        foreach ($vmHost in $vmHosts) {
            # Provera stanja hosta (ConnectionState + Maintenance mode)
            $connectionState = $vmHost.ConnectionState
            $inMaintenance   = $vmHost.ExtensionData.Runtime.InMaintenanceMode

            # ICMP ping (može biti blokiran firewall-om)
            $reachable = $false
            try {
                $reachable = Test-Connection -ComputerName $vmHost.Name -Count 1 -Quiet -ErrorAction SilentlyContinue
            } catch { $reachable = $false }

            # Mrežna konfiguracija
            $vSwitches  = @(Get-VirtualSwitch -VMHost $vmHost -ErrorAction SilentlyContinue)
            $portGroups = @(Get-VirtualPortGroup -VMHost $vmHost -ErrorAction SilentlyContinue)
            $vmKernels  = @(Get-VMHostNetworkAdapter -VMHost $vmHost -VMKernel -ErrorAction SilentlyContinue)

            # Licenca (može biti $null u zavisnosti od verzije PowerCLI-a)
            $licenseKey = $null
            try { $licenseKey = ($vmHost | Select-Object -ExpandProperty LicenseKey -ErrorAction SilentlyContinue) } catch {}

            $results.Add([PSCustomObject]@{
                Cluster         = $cluster.Name
                HostName        = $vmHost.Name
                ConnectionState = $connectionState
                MaintenanceMode = $inMaintenance
                ReachableICMP   = $reachable
                vSwitch         = ($vSwitches.Name -join ', ')
                PortGroups      = ($portGroups.Name -join ', ')
                VMKernels       = ($vmKernels.Name -join ', ')
                LicenseKey      = $licenseKey
            })
        }
    }

    if ($results.Count -gt 0) {
        $results | Export-Csv -Path $outFile -NoTypeInformation
        Write-Host "Završeno. CSV: $outFile"
    } else {
        Write-Warning "Nema podataka za izvoz."
    }
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    Disconnect-VIServer -Server $vCenter -Confirm:$false | Out-Null
}
