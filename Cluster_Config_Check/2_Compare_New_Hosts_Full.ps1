# 2_Compare_New_Hosts_Full.ps1
[CmdletBinding()]
param(
    [string]$vCenter = "hovcenter.rbj.co.yu",
    # Ako putanja nije validna, skripta æe sama pronaæi najnoviji Cluster_Config.csv
    [string]$baselinePath = "C:\Users\yuasubr\Documents\PowershellScript\Cluster_Config_Check\2025-10-27/Cluster_Config.csv",
    # Može biti jedan host ili CSV/razmak lista (npr. "h1,h2 h3")
    [string]$TargetHost = "",
    # Lista hostova (npr. -TargetHosts h1,h2 ili -TargetHosts @("h1","h2"))
    [string[]]$TargetHosts = @(),
    # Opcioni referentni host (zlatni standard)
    [string]$ReferenceHostName = "hoprodwin2esxi1.rbj.co.yu"
)

function SplitCsvList([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return @() }
    return ($s -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Sort-Object -Unique)
}
function Intersect([System.Collections.IEnumerable]$lists) {
    $arrs = @($lists | ForEach-Object { @($_) })
    if ($arrs.Count -eq 0) { return @() }
    $res = $arrs[0]
    if ($arrs.Count -gt 1) {
        foreach ($a in $arrs[1..($arrs.Count-1)]) { $res = $res | Where-Object { $a -contains $_ } }
    }
    return ($res | Sort-Object -Unique)
}
function CompareSets($expected, $actual) {
    $missing = @($expected | Where-Object { $actual -notcontains $_ })
    $extra   = @($actual   | Where-Object { $expected -notcontains $_ })
    [PSCustomObject]@{
        ContainsAll = ($missing.Count -eq 0)
        ExactMatch  = ($missing.Count -eq 0 -and $extra.Count -eq 0)
        Missing     = ($missing -join '; ')
        Extra       = ($extra -join '; ')
    }
}
function Sanitize([string]$n) {
    $short = ($n -split '\.')[0]
    return ($short -replace '[^\w\-\.]','_')
}
function Resolve-VMHostByName([string]$name) {
    $short = ($name -split '\.')[0]
    $vmHost = Get-VMHost -Name $name -ErrorAction SilentlyContinue
    if (-not $vmHost) { $vmHost = Get-VMHost -Name $short -ErrorAction SilentlyContinue }
    if (-not $vmHost) {
        $vmHost = Get-VMHost -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -eq $name -or $_.Name -eq $short
        } | Select-Object -First 1
    }
    return $vmHost
}

# Robusno prikupljanje ciljnih hostova (bez -join posle ForEach-Object)
$rawTargets = @()
if ($TargetHosts) { $rawTargets += $TargetHosts }
if (-not [string]::IsNullOrWhiteSpace($TargetHost)) { $rawTargets += $TargetHost }
if ($args.Count -gt 0) { $rawTargets += $args }

$collected = @()
foreach ($t in $rawTargets) {
    if ($null -eq $t) { continue }
    $s = $t.ToString().Trim()
    if (-not [string]::IsNullOrWhiteSpace($s)) {
        $collected += ($s -split '[,; \t]+' | Where-Object { $_ -and $_.Trim() })
    }
}
$TargetHosts = $collected | ForEach-Object { $_.Trim() } | Select-Object -Unique

if (-not $TargetHosts -or $TargetHosts.Count -eq 0) {
    $inputLine = Read-Host "Unesite ime(na) hosta(ova) odvojene zarezom ili razmakom"
    $TargetHosts = ($inputLine -split '[,; \t]+' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) | Select-Object -Unique
}
if (-not $TargetHosts -or $TargetHosts.Count -eq 0) {
    Write-Error "Niste naveli nijedan host za poreðenje."
    return
}

Write-Host ("Ciljni hostovi: {0}" -f ($TargetHosts -join ', '))

$ErrorActionPreference = 'Stop'
$cred = Get-Credential
Connect-VIServer -Server $vCenter -Credential $cred | Out-Null

# Pronaði baseline ako nije naveden ili ne postoji
if ([string]::IsNullOrWhiteSpace($baselinePath) -or -not (Test-Path -LiteralPath $baselinePath)) {
    $root = "C:\Users\yuasubr\Documents\PowershellScript\Cluster_Config_Check"
    $latest = Get-ChildItem -Path $root -Recurse -Filter "Cluster_Config.csv" -File -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) { throw "Nije pronaðen nijedan Cluster_Config.csv u '$root'. Pokreni skriptu 1." }
    $baselinePath = $latest.FullName
}

$baseline = Import-Csv -LiteralPath $baselinePath
if (-not $baseline) { throw "Baseline CSV je prazan: $baselinePath" }

# Oèekivanja: ReferenceHostName (ako je zadat) ili presek svih hostova iz baseline-a
$expVS  = @()
$expPG  = @()
$expVMK = @()
$expLic = $null
$source = "ClusterIntersection"

if ($ReferenceHostName) {
    $ref = $baseline | Where-Object { $_.HostName -eq $ReferenceHostName } | Select-Object -First 1
    if ($ref) {
        $expVS  = SplitCsvList $ref.vSwitch
        $expPG  = SplitCsvList $ref.PortGroups
        $expVMK = SplitCsvList $ref.VMKernels
        $expLic = $ref.LicenseKey
        $source = "ReferenceHost:$ReferenceHostName"
    } else {
        Write-Warning "ReferenceHostName '$ReferenceHostName' nije u baseline-u. Koristim presek klastera."
    }
}
if ($expVS.Count -eq 0 -and $baseline.Count -gt 0) {
    $expVS  = Intersect (@($baseline | ForEach-Object { SplitCsvList $_.vSwitch }))
    $expPG  = Intersect (@($baseline | ForEach-Object { SplitCsvList $_.PortGroups }))
    $expVMK = Intersect (@($baseline | ForEach-Object { SplitCsvList $_.VMKernels }))
    $expLic = ($baseline | Where-Object { $_.LicenseKey } |
               Group-Object LicenseKey | Sort-Object Count -Descending |
               Select-Object -First 1).Name
}

$timestamp = Get-Date -Format "yyyy-MM-dd"
$path = "C:\Users\yuasubr\Documents\PowershellScript\Cluster_Config_Check\$timestamp"
New-Item -ItemType Directory -Force -Path $path | Out-Null

# Dinamièko ime izlaznog fajla sa imenima hostova
$ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$shorts = $TargetHosts | ForEach-Object { Sanitize $_ }
if ($TargetHosts.Count -eq 1) {
    $namePart = $shorts[0]
} else {
    $namePart = ($shorts | Select-Object -First 3) -join '_'
    if ($TargetHosts.Count -gt 3) { $namePart += "_and$($TargetHosts.Count-3)more" }
}
$outFile = Join-Path $path ("compare_{0}_{1}.csv" -f $namePart, $ts)

$results = New-Object System.Collections.Generic.List[object]

foreach ($name in $TargetHosts) {
    $vmHost = Resolve-VMHostByName -name $name

    if (-not $vmHost) {
        Write-Warning "Host '$name' nije pronaðen u vCenter-u '$vCenter'."
        $results.Add([PSCustomObject]@{
            HostName               = $name
            vSwitch_ContainsAll    = $false
            vSwitch_ExactMatch     = $false
            vSwitch_Missing        = ($expVS -join '; ')
            vSwitch_Extra          = ""
            PortGroups_ContainsAll = $false
            PortGroups_ExactMatch  = $false
            PortGroups_Missing     = ($expPG -join '; ')
            PortGroups_Extra       = ""
            VMKernels_ContainsAll  = $false
            VMKernels_ExactMatch   = $false
            VMKernels_Missing      = ($expVMK -join '; ')
            VMKernels_Extra        = ""
            License_Match          = $false
            ExpectedLicense        = $expLic
            BaselineSource         = $source
        })
        continue
    }

    $vs  = @(Get-VirtualSwitch -VMHost $vmHost -ErrorAction SilentlyContinue).Name | Sort-Object -Unique
    $pg  = @(Get-VirtualPortGroup -VMHost $vmHost -ErrorAction SilentlyContinue).Name | Sort-Object -Unique
    $vmk = @(Get-VMHostNetworkAdapter -VMHost $vmHost -VMKernel -ErrorAction SilentlyContinue).Name | Sort-Object -Unique
    $lic = (Get-VMHost -Name $vmHost.Name -ErrorAction SilentlyContinue).LicenseKey

    $cmpVS  = CompareSets $expVS  $vs
    $cmpPG  = CompareSets $expPG  $pg
    $cmpVMK = CompareSets $expVMK $vmk

    $results.Add([PSCustomObject]@{
        HostName               = $vmHost.Name
        vSwitch_ContainsAll    = $cmpVS.ContainsAll
        vSwitch_ExactMatch     = $cmpVS.ExactMatch
        vSwitch_Missing        = $cmpVS.Missing
        vSwitch_Extra          = $cmpVS.Extra
        PortGroups_ContainsAll = $cmpPG.ContainsAll
        PortGroups_ExactMatch  = $cmpPG.ExactMatch
        PortGroups_Missing     = $cmpPG.Missing
        PortGroups_Extra       = $cmpPG.Extra
        VMKernels_ContainsAll  = $cmpVMK.ContainsAll
        VMKernels_ExactMatch   = $cmpVMK.ExactMatch
        VMKernels_Missing      = $cmpVMK.Missing
        VMKernels_Extra        = $cmpVMK.Extra
        License_Match          = ($expLic -and $lic -eq $expLic)
        ExpectedLicense        = $expLic
        BaselineSource         = $source
    })
}

$results | Export-Csv -Path $outFile -NoTypeInformation
Write-Host ("Završeno. CSV: {0}" -f $outFile)

Disconnect-VIServer -Server $vCenter -Confirm:$false | Out-Null

<# Primeri poziva:
- Jedan string sa zarezima/razmacima:
  .\2_Compare_New_Hosts_Full.ps1 -TargetHost "hoprodwin2esxi10.rbj.co.yu, hoprodwin2esxi11.rbj.co.yu, hoprodwin2esxi12.rbj.co.yu, hoprodwin2esxi13.rbj.co.yu, hoprodwin2esxi14.rbj.co.yu"
- Više hostova kao niz:
  .\2_Compare_New_Hosts_Full.ps1 -TargetHosts @("hoprodwin2esxi10.rbj.co.yu","hoprodwin2esxi11.rbj.co.yu","hoprodwin2esxi12.rbj.co.yu")
#>
