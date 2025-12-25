# Connect to the vCenter server
$vCenterServer = "drvcentercitrix.rbj.co.yu"
$credential = Get-Credential

Connect-VIServer -Server $vCenterServer -Credential $credential

# Loop through all connected vCenter servers
foreach ($vc in $global:DefaultVIServers) {
    # Get the License Manager view
    $licMgr = Get-View LicenseManager -Server $vc

    # Get the License Assignment Manager view
    $licAssignmentMgr = Get-View -Id $licMgr.LicenseAssignmentManager -Server $vc

    # Query assigned licenses and select relevant information
    $licenses = $licAssignmentMgr.QueryAssignedLicenses($vc.InstanceUid) | ForEach-Object {
        $_ | Select-Object @{N='vCenter';E={$vc.Name}},
                            EntityDisplayName,
                            @{N='LicenseKey';E={$_.AssignedLicense.LicenseKey}},
                            @{N='LicenseName';E={$_.AssignedLicense.Name}},
                            @{N='ExpirationDate';E={$_.AssignedLicense.Properties.Where{$_.Key -eq 'expirationDate'}.Value}}
    }

    # Output license information
    $licenses | Format-Table -AutoSize
}

# Disconnect from the vCenter server
Disconnect-VIServer -Server $vcServer -Confirm:$false