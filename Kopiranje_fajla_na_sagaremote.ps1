# Definišite deljenu lokaciju i destinaciju
$sourcePath = "\\rbj\datastore\IT_Division\IT Infrastructure Services and Help Desk\Core Infrastructure\IT Core Infrastructure Unit\VMWare_UPGRADE_2025_Software\U3b-c\VMware-ESXi-8.0.2-23825572-HPE-802.0.0.11.6.0.5-Aug2024.iso"
$destinationPath = "C:\Temp"

# Lista računara na koje želite da kopirate fajlove
$computers = @("sagaremote6", "sagaremote7", "sagaremote8")

foreach ($computer in $computers) {
    $destination = "\\$computer\C$\Temp"
    
    # Kreirajte temp folder ako ne postoji
    if (-not (Test-Path $destination)) {
        New-Item -ItemType Directory -Path $destination -Force
    }

    # Kopirajte fajlove
    Copy-Item -Path $sourcePath -Destination $destination -Recurse -Force
}