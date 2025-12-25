# Navedi korisnička imena koja želiš da proveriš
$usernames = @("yuamxk")

# Priključivanje na Active Directory modul
Import-Module ActiveDirectory

foreach ($username in $usernames) {
    # Nabavi informacije o korisniku
    $user = Get-ADUser -Identity $username -Properties "LockedOut"
    
    if ($user) {
        # Proveri da li je korisnički nalog zaključan
        if ($user.LockedOut) {
            Write-Output "${username}: Account is locked"
        } else {
            Write-Output "${username}: Account is not locked"
        }
    } else {
        Write-Output "${username}: User not found"
    }
}
