# Učitajte VMware PowerCLI modul
Import-Module VMware.PowerCLI

# Definišite vCenter server
$vCenterServer = "hovcenter.rbj.co.yu"  # Zamenite sa IP adresom ili imenom vCenter servera

# Koristite Get-Credential za unos korisničkog imena i lozinke
$credential = Get-Credential -Message "Unesite svoje vCenter korisničke podatke"

# Povežite se na vCenter server
Connect-VIServer -Server $vCenterServer -Credential $credential

# Definišite imena virtuelnih mašina
$vmNames = @("HORBRSCD","HORBRSCD2","swiftjumpsrv","splunksyslog1","rbrsdp02ho","PRINTTERM1","PRINTTERM10","PRINTTERM2","PRINTTERM3","PRINTTERM4","PRINTTERM5","PRINTTERM6","printterm7","printterm8","printterm9","prhsso1","prhsso2","posbe1","posbe2","BankReport2","pkafkacon2","HOUBSKIBDD","HOOPERATER","pkafkacon1","honiceuptivity","rbrscognos11","DMSAPP","DMSINDEX","dmsintcap1","dmsintcap2","dmsintcap3","dmsintcapt1","dmsintcapt2","dmsintcapt3","DMSINTEG","DMSINTEG2","DMSINTEG3","DMSINTEG4","DMSINTEG5""DMSINTEG6","dmsintel","dmsintelt","DMSNLB1","DMSNLB2","DMSNLB3","DMSOOS","DMSOOST","DMSPROXY","LNAPPLICATION1")  # Zamenite sa imenom vaših VM

# Kreirajte praznu listu za izveštaj
$report = @()

# Prođite kroz svaku virtuelnu mašinu
foreach ($vmName in $vmNames) {
    $vm = Get-VM -Name $vmName

    if ($vm) {
        $vmInfo = New-Object PSObject -Property @{
            Name      = $vm.Name
            MemoryGB  = [math]::round($vm.MemoryGB, 2)  # Memorija u GB
            CPUCount  = $vm.NumCpu
            Vlan      = ($vm.NetworkAdapters | Select-Object -ExpandProperty NetworkName) -join ", "
        }

        $report += $vmInfo
    }
}

# Izvezi izveštaj u CSV
$report | Export-Csv -Path "C:\temp\SRM_VM_report.csv" -NoTypeInformation

# Prikaži izveštaj
$report | Format-Table -AutoSize

# Odjavite se sa vCenter servera
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
