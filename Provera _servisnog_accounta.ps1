# Koristite Get-Credential za unos korisničkog imena i lozinke
$credential = Get-Credential -Message "Unesite servisni nalog i lozinku"

# Kreirajte LDAP putanju
$ldapPath = "ldap://10.233.239.201:3268"  # Zamenite sa vašim domain controller-om

try {
    # Pokušajte da se povežete
    $ldapConnection = New-Object DirectoryServices.DirectorySearcher
    $ldapConnection.SearchRoot = New-Object DirectoryServices.DirectoryEntry($ldapPath, $credential.UserName, $credential.GetNetworkCredential().Password)

    # Ako ne dođe do greške, lozinka je ispravna
    $null = $ldapConnection.SearchRoot.NativeObject
    Write-Host "Lozinka je ispravna."
} catch {
    Write-Host "Lozinka nije ispravna: $_"
}
