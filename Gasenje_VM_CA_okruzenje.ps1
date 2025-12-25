# Povežite se na vCenter Server
$vCenterServer = "ucsvcenter.bankmeridian.com"

Connect-VIServer -Server $vCenterServer -User $username -Password $password

# Učitajte listu virtuelnih mašina
$vmListFile = "C:\Temp\Masine_Gasenje\Lista_za_gasenje.txt"
$vmNames = Get-Content -Path $vmListFile

foreach ($vmName in $vmNames) {
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm) {
        if ($vm.PowerState -eq "PoweredOn") {
            # Pokušaj urednog gašenja VM-a
            Shutdown-VMGuest -VM $vm -Confirm:$false -ErrorAction SilentlyContinue

            # Sačekajmo neko vreme da se VM ugasi na uredan način
            Start-Sleep -Seconds 60

            # Ponovo dohvati VM da osveži status
            $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue

            if ($vm.PowerState -ne "PoweredOff") {
                # Ako VM nije ugašen, koristite hard off
                Stop-VM -VM $vm -Confirm:$false -ErrorAction SilentlyContinue
                Write-Output "VM '$vmName' nije mogla biti uredno ugašena, korišten je hard off."
            } else {
                Write-Output "VM '$vmName' je uredno ugašena."
            }
        } else {
            Write-Output "VM '$vmName' je već ugašena."
        }
    } else {
        Write-Output "VM '$vmName' nije pronađena."
    }
}

# Prekinite vezu sa vCenter Serverom
Disconnect-VIServer -Server $vCenterServer -Confirm:$false