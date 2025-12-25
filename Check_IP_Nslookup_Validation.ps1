# Definišite IP adrese koje želite da proverite
$ipAddresses = @("172.30.0.38",
"10.234.7.18",
"10.234.7.24",
"10.234.7.28",
"10.234.7.25",
"10.234.7.16",
"10.234.7.26",
"10.234.6.90",
"10.234.7.27",
"10.234.6.93",
"10.234.7.12",
"10.234.7.11",
"10.234.7.19",
"10.234.7.14",
"10.234.7.13",
"10.234.6.248",
"10.234.7.15",
"10.234.7.29",
"172.30.0.47",
"10.234.6.92",
"10.234.6.249",
"10.234.7.17",
"172.30.0.46",
"10.234.6.95",
"10.234.6.91")

# Kreirajte prazan niz za izveštaj
$report = @()

foreach ($ip in $ipAddresses) {
    $pingResult = Test-Connection -ComputerName $ip -Count 1 -Quiet
    $nslookupResult = nslookup $ip 2>&1

    if ($pingResult -and $nslookupResult -notmatch "can't find") {
        $status = "Valid"
    } else {
        $status = "Invalid"
    }

    $report += [PSCustomObject]@{
        IPAddress = $ip
        PingStatus = $pingResult
        NslookupStatus = if ($nslookupResult -notmatch "can't find") { "Success" } else { "Failed" }
        Status = $status
    }
}

# Izbacite izveštaj
$report | Format-Table -AutoSize