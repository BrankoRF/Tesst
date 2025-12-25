# Učitaj VMware PowerCLI modul
Import-Module VMware.PowerCLI

# Poveži se na vCenter Server
$vCenterServer = "hovcenter.rbj.co.yu"

$credential = Get-Credential

Connect-VIServer -Server $vCenterServer -Credential $credential

# Dobij listu svih hostova
$vmHosts = Get-VMHost

# Proveri status SSH servisa na svakom hostu
foreach ($vmHost in $vmHosts) {
    $sshService = Get-VMHostService -VMHost $vmHost | Where-Object {$_.Key -eq "TSM-SSH"}
    if ($sshService.Running) {
        Write-Host "SSH is enabled on host: $($vmHost.Name)"
    } else {
        Write-Host "SSH is disabled on host: $($vmHost.Name)"
    }
}

# Diskonektuj se sa vCenter Server-a
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
