Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false >/dev/null 2>&1
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false >/dev/null 2>&1
$vCenter = $args[0]
Connect-VIServer $vCenter -User nagios@vsphere.local -Password beograd011 *> $null

$poruka = ""

# Get all DS from vCenter
$datastores = (Get-Datastore).where{$_.Name -notmatch '.*boot.*|.*VR.*|.*lib.*'}

# Get VMs info
foreach ($datastore in $datastores) {
    $vms = Get-VM -Datastore $datastore

    if ($vms.Count -eq 0) {
        if ($poruka -eq "") {
          $poruka = $datastore.Name
        } else {
          $poruka = "$poruka" + ", " + $datastore
        }
    }
}

Disconnect-VIServer -Server * -Confirm:$false

if ($poruka -eq "") {
    echo "No datastores without VMs."
    exit 0
} else {
    echo "Datastores w/o VMs: $poruka."
    exit 1
}