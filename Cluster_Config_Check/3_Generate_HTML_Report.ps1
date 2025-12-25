# 3_Generate_HTML_Report.ps1
param(
    [string]$csvPath = "C:\Users\yuasubr\Documents\PowershellScript\Cluster_Config_Check\2025-10-27\compare_new_hosts_results.csv"
)

$csv = Import-Csv $csvPath
$html = @()
$html += "<html><head><title>Cluster Config Report</title>"
$html += "<style>body{font-family:Segoe UI;}table{border-collapse:collapse;}td,th{border:1px solid #ccc;padding:8px;}"
$html += ".ok{background-color:#c8f7c5}.fail{background-color:#f7c5c5}</style></head><body>"
$html += "<h2>Cluster Configuration Comparison Report</h2>"
$html += "<table><tr><th>Host</th><th>vSwitch</th><th>PortGroups</th><th>VMKernels</th><th>License</th></tr>"

foreach ($row in $csv) {
    $html += "<tr>"
    $html += "<td>$($row.HostName)</td>"
    foreach ($field in @('vSwitch_Match','PortGroups_Match','VMKernels_Match','License_Match')) {
        $class = if ($row.$field -eq 'True') {'ok'} else {'fail'}
        $html += "<td class='$class'>$($row.$field)</td>"
    }
    $html += "</tr>"
}
$html += "</table></body></html>"

$outFile = [System.IO.Path]::ChangeExtension($csvPath, ".html")
$html -join "`n" | Out-File $outFile -Encoding utf8
Write-Host "HTML izveštaj generisan: $outFile"
