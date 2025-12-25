
Connect-VIServer -Server hovcenter.rbj.co.yu

$credential = Get-Credential

# Lista virtualnih mašina
#$vmList = @("VM1", "VM2", "VM3")
$vmList = @("rbaarhivaws13")


# Loop kroz svaku VM
foreach ($vm in $vmList) {
    Write-Host "Procesiranje virtualne mašine: $vm"
    
    # Priključivanje na VM
    $vmObject = Get-VM -Name $vm 

    if ($vmObject) {
        # Deinstalacija VMware Tools
        Uninstall-VMGuest -VM $vmObject -Confirm:$false
        Write-Host "VMware Tools deinstaliran za $vm"
        
        # Restart posle deinstalacije
        Restart-VMGuest -VM $vmObject -Confirm:$false
        Write-Host "Virtualna mašina $vm je restartovana nakon deinstalacije VMware Tools"

        # Dodajte pauzu ako je potrebno vremena za potpun restart (npr. 2 minute)
        Start-Sleep -Seconds 120

        # Instalacija VMware Tools nakon restartovanja
        Install-VMGuest -VM $vmObject -Confirm:$false
        Write-Host "VMware Tools instaliran za $vm"

        # Restart posle instalacije
        Restart-VMGuest -VM $vmObject -Confirm:$false
        Write-Host "Virtualna mašina $vm je restartovana nakon instalacije VMware Tools"

        # Dodajte pauzu ako je potrebno vremena za potpun restart (npr. 2 minute)
        Start-Sleep -Seconds 120
    } else {
        Write-Host "Virtualna mašina $vm nije pronađena"
    }
}
