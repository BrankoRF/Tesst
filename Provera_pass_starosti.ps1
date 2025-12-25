# Navedi korisnička imena koja želiš da proveriš
$usernames = @("username", "username", "username")

# Priključivanje na Active Directory modul
Import-Module ActiveDirectory

foreach ($username in $usernames) {
    # Nabavi informacije o korisniku
    $user = Get-ADUser -Identity $username -Properties "PasswordLastSet"
    
    if ($user) {
        # Izračunaj starost lozinke
        $passwordAge = (Get-Date) - $user.PasswordLastSet
        
        # Prikaži rezultat
        Write-Output "${username}: Password last set $($user.PasswordLastSet) - $([math]::Round($passwordAge.TotalDays)) days ago"
    } else {
        Write-Output "${username}: User not found"
    }
}
