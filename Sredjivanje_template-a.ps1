Add-Type -AssemblyName System.Windows.Forms

# Funkcija za autentifikaciju na vCenter
function Authenticate-vCenter {
    $credential = Get-Credential -Message "Unesite svoje vCenter kredencijale"
    Connect-VIServer -Server 'vcenter_server' -Credential $credential
}

function Get-Clusters {
    return Get-Cluster | Select-Object -ExpandProperty Name
}

function Get-DatastoreClusters {
    return Get-DatastoreCluster | Select-Object -ExpandProperty Name
}

function Create-VM {
    param (
        [string]$clusterName,
        [string]$datastoreName,
        [string]$vmName
    )
    # Primer koda za kreiranje VM
    New-VM -Name $vmName -ResourcePool (Get-ResourcePool -Cluster $clusterName) -Datastore (Get-Datastore -DatastoreCluster $datastoreName)
    Write-Host "Kreirana VM '$vmName' u klasteru '$clusterName' na datastore '$datastoreName'."
}

function Convert-VMToTemplate {
    param (
        [string]$vmName
    )
    # Primer koda za konverziju VM u template
    $vm = Get-VM -Name $vmName
    if ($vm) {
        Set-Template -VM $vm -Confirm:$false
        Write-Host "VM '$vmName' je konvertovan u template."
    } else {
        Write-Host "VM '$vmName' nije pronađen."
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'VMware Management'
$form.Size = New-Object System.Drawing.Size(500, 500)

$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = 'Fill'

# Tab za kreiranje nove VM
$createTab = New-Object System.Windows.Forms.TabPage
$createTab.Text = 'Kreiraj VM'

$clusterLabel = New-Object System.Windows.Forms.Label
$clusterLabel.Text = 'Odaberite klaster:'
$clusterLabel.Location = New-Object System.Drawing.Point(10, 20)

$clusterComboBox = New-Object System.Windows.Forms.ComboBox
$clusterComboBox.Location = New-Object System.Drawing.Point(10, 40)
$clusterComboBox.Items.AddRange(Get-Clusters)

$datastoreLabel = New-Object System.Windows.Forms.Label
$datastoreLabel.Text = 'Odaberite datastore klaster:'
$datastoreLabel.Location = New-Object System.Drawing.Point(10, 80)

$datastoreComboBox = New-Object System.Windows.Forms.ComboBox
$datastoreComboBox.Location = New-Object System.Drawing.Point(10, 100)
$datastoreComboBox.Items.AddRange(Get-DatastoreClusters)

$vmNameLabel = New-Object System.Windows.Forms.Label
$vmNameLabel.Text = 'Ime nove VM:'
$vmNameLabel.Location = New-Object System.Drawing.Point(10, 140)

$vmNameTextBox = New-Object System.Windows.Forms.TextBox
$vmNameTextBox.Location = New-Object System.Drawing.Point(10, 160)

$createButton = New-Object System.Windows.Forms.Button
$createButton.Text = 'Kreiraj VM'
$createButton.Location = New-Object System.Drawing.Point(10, 200)
$createButton.Add_Click({
    $clusterName = $clusterComboBox.SelectedItem
    $datastoreName = $datastoreComboBox.SelectedItem
    $vmName = $vmNameTextBox.Text
    Create-VM -clusterName $clusterName -datastoreName $datastoreName -vmName $vmName
})

$createTab.Controls.AddRange(@($clusterLabel, $clusterComboBox, $datastoreLabel, $datastoreComboBox, $vmNameLabel, $vmNameTextBox, $createButton))
$tabControl.TabPages.Add($createTab)

# Tab za konverziju VM u template
$convertTab = New-Object System.Windows.Forms.TabPage
$convertTab.Text = 'Konvertuj u Template'

$vmNameConvertLabel = New-Object System.Windows.Forms.Label
$vmNameConvertLabel.Text = 'Ime VM za konverziju:'
$vmNameConvertLabel.Location = New-Object System.Drawing.Point(10, 20)

$vmNameConvertTextBox = New-Object System.Windows.Forms.TextBox
$vmNameConvertTextBox.Location = New-Object System.Drawing.Point(10, 40)

$convertButton = New-Object System.Windows.Forms.Button
$convertButton.Text = 'Konvertuj u Template'
$convertButton.Location = New-Object System.Drawing.Point(10, 80)
$convertButton.Add_Click({
    $vmName = $vmNameConvertTextBox.Text
    Convert-VMToTemplate -vmName $vmName
})

$convertTab.Controls.AddRange(@($vmNameConvertLabel, $vmNameConvertTextBox, $convertButton))
$tabControl.TabPages.Add($convertTab)

# Poziv funkcije za autentifikaciju
Authenticate-vCenter

$form.Controls.Add($tabControl)
$form.ShowDialog()
