Connect-VIServer $vCenter -User nagios@vsphere.local -Password beograd011 *> $null

$poruka = ""

# Definiši ekskluzivnu listu datastore-ova koje treba isključiti
$excludeList = @('datastore1', 'datastore2', 'datastore3') # Dodaj imena datastore-ova koje želiš da isključiš

# Get all DS from vCenter
$datastores = (Get-Datastore).where{
    $_.Name -notmatch '.*boot.*|.*VR.*|.*lib.*' -and
    $_.Name -notin $excludeList
}

# Get VMs info
foreach ($datastore in $datastores) {
    $vms = Get-VM -Datastore $datastore

    if ($vms.Count -eq 0) {
        if ($poruka -eq "") {
            $poruka = $datastore.Name
        } else {
            $poruka = "$poruka" + ", " + $datastore.Name
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
