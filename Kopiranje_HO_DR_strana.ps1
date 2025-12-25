# Definišite putanju za log fajl
$logFilePath = "C:\Users\yuasubr\Documents\PowershellScript\Report\logfile.txt"  # Zamenite sa stvarnom putanjom

# Funkcija za logovanje
function Log-Action {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    "$timestamp - $message" | Out-File -FilePath $logFilePath -Append -Encoding utf8
}

# Autentifikacija na HO vCenter
$hoCredential = Get-Credential -Message "Unesite svoje vCenter kredencijale za HO-strana"
$ho = Connect-VIServer -Server "Hovcenter.rbj.co.yu" -Credential $hoCredential
Log-Action "Povezan na HO vCenter."

# Autentifikacija na DR vCenter
$drCredential = Get-Credential -Message "Unesite svoje vCenter kredencijale za DR-strana"
$dr = Connect-VIServer -Server "drvcenter.rbj.co.yu" -Credential $drCredential
Log-Action "Povezan na DR vCenter."

# VM koja se migruje
$vmName = "Microsoft Windows Server 2022 Standard_DR"  # Unesite ime VM-a koji se migruje
$vm = Get-VM -Server $ho -Name $vmName

if ($vm -eq $null) {
    Log-Action "VM '$vmName' nije pronađen na HO vCenter."
    exit
} else {
    Log-Action "Pronađena VM '$vmName' na HO vCenter."
}

# Nova lokacija na drugom vCentru
$novaLokacija = @{
    Server = $dr
    Datastore = Get-Datastore -Server $dr -Name "dresxi-lib-kg370-07.07"  # Unesite ime datastore-a
    Destination = Get-VMHost -Server $dr -Name "drprodesxi6.rbj.co.yu"  # Unesite ime hosta
    InventoryLocation = Get-Folder -Server $dr -Type VM -Name "Domain Unit servers"  # Unesite lokaciju
   # PortGroup = Get-VMHost -Server $dr -Name "drprodesxi6.rbj.co.yu" | Get-VirtualPortGroup -Server $dr -Name "VLAN79"  # Unesite VLANID
}

# Provera desinacije
Log-Action "Nova lokacija za migraciju: $($novaLokacija | Out-String)"

# Migracija same mašine
try {
    $vm | Move-VM @novaLokacija
    Log-Action "Migracija VM '$vmName' završena uspešno."
} catch {
    Log-Action "Došlo je do greške prilikom migracije VM '$vmName': $_"
}
