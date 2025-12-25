# Učitaj Excel COM objekt
$excel = New-Object -ComObject Excel.Application
$excel.Visible = $false

# Otvori Excel dokument
$workbook = $excel.Workbooks.Open("C:\putanja\do\vašeg\excel\dokumenta.xlsx")

# Pretpostavimo da su podaci u prvom radnom listu
$sheet = $workbook.Sheets.Item(1)

# Dobij broj redova sa podacima
$usedRange = $sheet.UsedRange
$rowCount = $usedRange.Rows.Count
$colCount = $usedRange.Columns.Count

# Prikaz kolona za izbor
Write-Host "Kolone u Excel dokumentu:"
for ($j = 1; $j -le $colCount; $j++) {
    $columnHeader = $sheet.Cells.Item(1, $j).Text
    Write-Host "$j: $columnHeader"
}

# Unos korisnika za kolone ID i Task Name
$idColumns = Read-Host "Unesite brojeve kolona za ID, odvojene zarezima"
$taskNameColumns = Read-Host "Unesite brojeve kolona za Task Name, odvojene zarezima"

# Pretvori unose u nizove
$idColumnsArray = $idColumns -split ","
$taskNameColumnsArray = $taskNameColumns -split ","

# Prođi kroz sve redove (pretpostavljamo da prvi red sadrži zaglavlja)
for ($i = 2; $i -le $rowCount; $i++) {
    foreach ($idColumn in $idColumnsArray) {
        foreach ($taskNameColumn in $taskNameColumnsArray) {
            $id = $sheet.Cells.Item($i, [int]$idColumn.Trim()).Text
            $taskName = $sheet.Cells.Item($i, [int]$taskNameColumn.Trim()).Text

            # Kreiraj email
            $outlook = New-Object -ComObject Outlook.Application
            $mail = $outlook.CreateItem(0)
            $mail.Subject = "$id - $taskName"
            $mail.Body = "Ovo je telo emaila za task $taskName sa ID $id."
            $mail.To = "primatelj@example.com"
            
            # Prikaži email (umesto da ga odmah pošalješ)
            $mail.Display($false)
        }
    }
}

# Zatvori Excel dokument bez čuvanja
$workbook.Close($false)
$excel.Quit()

# Oslobodi COM objekte
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($sheet) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook) | Out-Null
[System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null

# Pokupi smeće
[GC]::Collect()
[GC]::WaitForPendingFinalizers()