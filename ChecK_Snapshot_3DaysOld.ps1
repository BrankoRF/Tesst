Connect-VIServer -Server hovcenter.rbj.co.yu
$credential = Get-Credential

# Dobavljanje svih snapshotova na vSphere platformi
$snapshots = Get-VM | Get-Snapshot

# Datum od kojeg ćemo računati starost snapshota
$thresholdDate = (Get-Date).AddDays(-3)

# Iteriranje kroz sve snapshotove i provjera njihove starosti
foreach ($snapshot in $snapshots) {
    $snapshotAge = (Get-Date) - $snapshot.Created
    if ($snapshotAge.TotalDays -gt 3) {
        Write-Host "Snapshot '$($snapshot.Name)' na virtualnom računalu '$($snapshot.VM)' je stariji od 3 dana."
        # Dodajte dodatne radnje prema potrebi, npr. brisanje snapshota
    }
}

# Odjava sa vCenter Servera
Disconnect-VIServer -Server * -Confirm:$false