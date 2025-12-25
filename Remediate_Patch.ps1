# Povezivanje na VMware vCenter server
Connect-VIServer -Server <vCenterServer> -User <username> -Password <password>

# Naziv hosta koji želite remedirati
$hostName = "NazivVašegHosta"

# Pronalaženje hosta
$host = Get-VMHost -Name $hostName

# Pronalaženje dostupnih remedijacija za host
$remediations = Get-VMHostPatch -VMHost $host

# Izlistavanje dostupnih remedijacija
$remediations | Format-Table -Property Name, Description, Installed, InstalledBy, InstallDate

# Odabir željene remedijacije
$selectedRemediation = $remediations | Where-Object { $_.Name -eq "ImeVašeRemedijacije" }

# Remedijacija hosta
if ($selectedRemediation -ne $null) {
    Write-Host "Izabrana remedijacija: $($selectedRemediation.Name)"
    Start-VMHostPatch -VMHost $host -HostPath $selectedRemediation
} else {
    Write-Host "Remedijacija nije pronađena ili izabrana."
}

# Odspajanje sa vCenter serverom
Disconnect-VIServer -Confirm:$false
