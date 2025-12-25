# Učitaj VMware PowerCLI modul
Import-Module VMware.PowerCLI

# Poveži se na vCenter Server
$vCenterServer = "drvcenter.rbj.co.yu"

$credential = Get-Credential

Connect-VIServer -Server $vCenterServer -Credential $credential

# Definiši UUID datastora koji želiš da proveriš
$datastoreUUID = "60060e80223c2b0050413c2b00000332"

# Pronađi datastor koristeći UUID
$datastore = Get-Datastore | Where-Object { $_.ExtensionData.Info.Vmfs.Uuid -eq $datastoreUUID }

if ($datastore) {
    Write-Output "Datastore sa UUID '$datastoreUUID' je pronađen. Ime datastora: $($datastore.Name)"

    # Pronađi sve VM-ove koji koriste ovaj datastor
    $vmsUsingDatastore = Get-VM | Where-Object {
        $_.ExtensionData.Config.DatastoreUrl | Where-Object { $_.Name -eq $datastore.Name }
    }

    if ($vmsUsingDatastore) {
        Write-Output "Virtuelne mašine koje koriste datastore '$($datastore.Name)':"
        $vmsUsingDatastore | ForEach-Object { Write-Output $_.Name }
    } else {
        Write-Output "Nema virtuelnih mašina koje koriste datastore '$($datastore.Name)'."
    }
} else {
    Write-Output "Datastore sa UUID '$datastoreUUID' nije pronađen."
}

# Diskonektuj se sa vCenter Server-a
Disconnect-VIServer -Server $vCenterServer -Confirm:$false