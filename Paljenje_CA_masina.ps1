# Povežite se na vCenter Server
$vCenterServer = "ucsvcenter.bankmeridian.com"

Connect-VIServer -Server $vCenterServer -User $username -Password $password

# Učitajte listu virtuelnih mašina
$vmListFile = "C:\Temp\Masine_Gasenje\Lista_za_gasenje.txt"
$vmNames = Get-Content -Path $vmListFile

foreach ($vmName in $vmNames) {
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm) {
        # Uključite VM
        Start-VM -VM $vm -Confirm:$false
        Write-Output "VM '$vmName' je uključena."
    } else {
        Write-Output "VM '$vmName' nije pronađena."
    }
}

# Prekinite vezu sa vCenter Serverom
Disconnect-VIServer -Server $vCenterServer -Confirm:$false