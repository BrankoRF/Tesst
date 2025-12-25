# Definišite SMTP server i port za slanje email-a
$smtpServer = "smtp.example.com"
$smtpPort = 587

# Definišite kredencijale za prijavljivanje na SMTP server
$smtpUsername = "your_username"
$smtpPassword = "your_password"

# Definišite primaoca, pošiljaoca i subject email-a
$recipient = "recipient@example.com"
$sender = "sender@example.com"
$subject = "Subject email-a"

# Putanja do HTML fajla koji sadrži vaš mail template
$templatePath = "C:\putanja\do\template.html"

# Učitajte sadržaj HTML template-a
$templateContent = Get-Content -Path $templatePath | Out-String

# Šaljite email
Send-MailMessage -From $sender -To $recipient -Subject $subject -SmtpServer $smtpServer -Port $smtpPort -Credential (New-Object System.Management.Automation.PSCredential -ArgumentList ($smtpUsername, (ConvertTo-SecureString -String $smtpPassword -AsPlainText -Force))) -UseSsl -Body $templateContent -BodyAsHtml
