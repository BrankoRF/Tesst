# Učitaj VMware PowerCLI modul
Import-Module VMware.PowerCLI

# Poveži se na vCenter Server
$vcenterServer = "drvcenter.rbj.co.yu"
$credential = Get-Credential
Connect-VIServer -Server $vcenterServer -Credential $credential

# Naziv VM šablona koji želiš da proveriš
$templateName = "RHEL83"

# Pronađi VM šablon
$template = Get-Template -Name $templateName

if ($template) {
    # Pronađi sve VM instance koje su kreirane iz ovog šablona
    $vmsUsingTemplate = Get-VM | Where-Object { $_.ExtensionData.Config.Template -eq $template.ExtensionData.Config.Template }
    
    if ($vmsUsingTemplate.Count -gt 0) {
        Write-Host "Šablon '$templateName' je u upotrebi od strane sledećih VM-ova:"
        $vmsUsingTemplate | ForEach-Object { Write-Host $_.Name }
    } else {
        Write-Host "Šablon '$templateName' nije u upotrebi od strane nijednog VM-a."
    }
} else {
    Write-Host "Šablon '$templateName' nije pronađen."
}

# Prekini vezu sa vCenter Serverom
Disconnect-VIServer -Server $vcenterServer -Confirm:$false
