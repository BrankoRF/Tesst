# (Opcionalno) Povezivanje
 Connect-VIServer -Server 'drvcenter.rbj.co.yu' -Credential (Get-Credential)
# Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Isključenja - upiši tačno kako želiš
$excludedRaw = @(
    'DRCBSAPP1','DRCBSAPP2','DRCBSAPP3','DRCBSAPP4',
    'posbe1','posbe2',
    'HODPS','HODPS1',
    'prhsso1','prhsso2',
    'pkafkacon1','pkafkacon2',
    'DMSNLB',
    'HODMSSQLN',
    'hodmsfs',
    'ipsapp',
    'dmsintcap',
    'PRINTTERM'
)

function Get-BaseName([string]$name) {
    # Ukloni završno 1/2 i razmake
    return ($name -replace '[12]$','').Trim()
}

# Napravi skup baznih imena za isključenje (case-insensitive)
$excludedBaseSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$excludedRaw | ForEach-Object { [void]$excludedBaseSet.Add((Get-BaseName $_)) }

# Preskoči placeholder datastorove (po potrebi stavi $false)
$skipPlaceholderDS = $true

# Datastore-ovi sa ≥2 VM-a
$datastores = Get-Datastore | Where-Object {
    (-not $skipPlaceholderDS -or $_.Name -notmatch 'Placeholder') -and
    (Get-VM -Datastore $_ -ErrorAction SilentlyContinue).Count -ge 2
}

$iswarn = $false
$doubles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

foreach ($ds in $datastores) {
    $vms = Get-VM -Datastore $ds -ErrorAction SilentlyContinue
    if (-not $vms) { continue }

    # Brzi skup imena VM-ova (Trim + case-insensitive)
    $vmNameSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $vms.Name | ForEach-Object { [void]$vmNameSet.Add($_.Trim()) }

    foreach ($vm in $vms) {
        $vmName = $vm.Name.Trim()
        $baseForSkip = Get-BaseName $vmName
        if ($excludedBaseSet.Contains($baseForSkip)) { continue }

        # Radi samo sa VM-ovima koji završavaju na "1"
        if ($vmName -match '^(.*)1$') {
            $base  = $Matches[1].Trim()
            $base2 = "${base}2"

            # Traži par: base + base1 ili base1 + base2
            if ($vmNameSet.Contains($base) -or $vmNameSet.Contains($base2)) {
                $clusterName = ($vm.VMHost.Parent).Name
                if ($clusterName -notmatch 'Test|remote') {
                    $key = "$base/$($ds.Name)"
                    if ($doubles.Add($key)) {
                        Write-Host -NoNewline "$key "
                        $iswarn = $true
                    }
                }
            }
        }
    }
}

if (-not $iswarn) { Write-Host 'No matches found.' }