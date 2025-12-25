#!/usr/bin/pwsh

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false *> $null
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false *> $null

$vCenter = $args[0]
Connect-VIServer $vCenter -User "msssevvs@vsphere.local" -Password "zvsszz" *> $null

# Skupi imena VM-ova koje imaju bar jedan diskonektovan adapter
$vmNames = Get-VM | ForEach-Object {
    $vm = $_
    $hasDisconnected = Get-NetworkAdapter -VM $vm | Where-Object {
        $_.ConnectionState.Connected -eq $false
    }
    if ($hasDisconnected) {
        $vm.Name
    }
} | Sort-Object -Unique



# ISPIS U JEDNOM REDU
if (-not $vmNames -or $vmNames.Count -eq 0) {
    Write-Output "No VMs with disconnected network adapters."
    exit 0
} else {
    Write-Output ($vmNames -join " ")
    exit 1
}
# Odjavljivanje sa vCenter servera
Disconnect-VIServer -Server $vCenter -Confirm:$false *> $null