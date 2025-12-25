Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm
$vCenter = $args[0]
Connect-VIServer $vCenter -User nagios@vsphere.local -Password beograd011

# Calculate limit date (30 days ago)
$limitDate = (Get-Date).AddDays(-30)

# Get All VMs
$poweredoffVM = Get-VM | Where-Object { $_.PowerState -eq "PoweredOff" }

# Powered VMs 30 days or more
$filterVM = $poweredoffVM | Where-Object { $_.ExtensionData.Runtime.PowerStateChangeTime -lt $limitDate }

# Check powered off VMs
if ($filterVM.Count -eq 0) {

    Write-Host " No VMs powered off 30 days or more ."
    exit 0
} else {

    Write-Host "Powered off VMs: $filterVM "
    exit 1
}

# Odjavljivanje sa vCenter servera
Disconnect-VIServer -Server $vCenter -Confirm

