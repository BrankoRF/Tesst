# Koristite Get-Credential za unos korisničkog imena i lozinke
$credential = Get-Credential -Message "Unesite korisničko ime i lozinku za LDAP"

# Kreirajte LDAP putanju
$ldapPath = "ldap://10.233.239.201:3268"  # Zamenite sa vašim domain controller-om
$groupName = "ADM CORE"  # Zamenite sa imenom grupe koju želite da pretražujete

try {
    # Pokušajte da se povežete
    $ldapConnection = New-Object DirectoryServices.DirectoryEntry($ldapPath, $credential.UserName, $credential.GetNetworkCredential().Password)

    # Ako ne dođe do greške, lozinka je ispravna
    $null = $ldapConnection.NativeObject
    Write-Host "Lozinka je ispravna."

    # Sada pretražujemo članove grupe
    $searcher = New-Object DirectoryServices.DirectorySearcher($ldapConnection)
    $searcher.Filter = "(&(objectClass=group)(cn=$groupName))"
    $searcher.PropertiesToLoad.Add("member")

    $result = $searcher.FindOne()

    if ($result -ne $null) {
        $members = $result.Properties["member"]

        Write-Host "Članovi grupe '$groupName':"
        foreach ($member in $members) {
            Write-Host $member
        }
    } else {
        Write-Host "Grupa '$groupName' nije pronađena."
    }
} catch {
    Write-Host "Došlo je do greške: $_"
}
