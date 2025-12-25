# Definišite korisničko ime i lozinku
$credential = Get-Credential -Message "Unesite servisni nalog i lozinku"

# Kreirajte SecureString za lozinku
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force

# Kreirajte LDAP putanju
$ldapPath = "ldap://10.233.239.201:3268"  # Zamenite sa vašim domain controller-om

try {
    # Pokušajte da se povežete
    $ldapConnection = New-Object DirectoryServices.DirectoryEntry($ldapPath, $credential.UserName, $credential.GetNetworkCredential().Password)


    # Ako ne dođe do greške, lozinka je ispravna
    $null = $ldapConnection.NativeObject
    Write-Host "Lozinka je ispravna."

    # Sada proverite da li je nalog zaključan
    $searcher = New-Object DirectoryServices.DirectorySearcher($ldapConnection)
    $searcher.Filter = "(&(objectClass=user)(sAMAccountName=$($username.Split('\')[1])))"
    $searcher.PropertiesToLoad.Add("lockoutTime")

    $result = $searcher.FindOne()

    if ($result -ne $null) {
        $lockoutTime = $result.Properties["lockoutTime"]

        if ($lockoutTime -and $lockoutTime[0] -ne 0) {
            Write-Host "Korisnički nalog je zaključan."
        } else {
            Write-Host "Korisnički nalog nije zaključan."
        }
    } else {
        Write-Host "Korisnički nalog nije pronađen."
    }
} catch {
    Write-Host "Lozinka nije ispravna ili došlo je do greške: $_"
}
