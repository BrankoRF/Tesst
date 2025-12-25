Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Definisanje glavnog forma
$form = New-Object System.Windows.Forms.Form
$form.Text = "PowerCLI VLAN Manager"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"

# Labela - izbor vCenter
$labelVCenter = New-Object System.Windows.Forms.Label
$labelVCenter.Text = "Izaberite vCenter:"
$labelVCenter.Location = New-Object System.Drawing.Point(20, 20)
$labelVCenter.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelVCenter)

# ComboBox za vCenter
$comboVCenter = New-Object System.Windows.Forms.ComboBox
$comboVCenter.Location = New-Object System.Drawing.Point(140,18)
$comboVCenter.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($comboVCenter)
$comboVCenter.Items.AddRange(@('Vcenter1.co.yu', 'DRvcenter1.co.yu'))
$comboVCenter.SelectedIndex = 0

# Duplo labela za status konekcije
$labelStatus = New-Object System.Windows.Forms.Label
$labelStatus.Location = New-Object System.Drawing.Point(20, 50)
$labelStatus.Size = New-Object System.Drawing.Size(500, 20)
$form.Controls.Add($labelStatus)

# Dugme za konekciju
$buttonConnect = New-Object System.Windows.Forms.Button
$buttonConnect.Location = New-Object System.Drawing.Point(460, 15)
$buttonConnect.Size = New-Object System.Drawing.Size(100, 25)
$buttonConnect.Text = "Poveži se"
$form.Controls.Add($buttonConnect)

# Labela - Izbor opcije
$labelOpcija = New-Object System.Windows.Forms.Label
$labelOpcija.Text = "Izaberite opciju:"
$labelOpcija.Location = New-Object System.Drawing.Point(20, 90)
$labelOpcija.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelOpcija)

# ComboBox - Opcije
$comboOpcije = New-Object System.Windows.Forms.ComboBox
$comboOpcije.Location = New-Object System.Drawing.Point(140, 88)
$comboOpcije.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($comboOpcije)
$comboOpcije.Items.AddRange(@(
    'Add VLAN to cluster',
    'Add VLAN to host',
    'Add cluster VLANs to host',
    'Add cluster VLANs to another cluster'
))
$comboOpcije.Enabled = $false

# Labela i ComboBox za klaster (puni se posle konekcije)
$labelCluster1 = New-Object System.Windows.Forms.Label
$labelCluster1.Text = "Izaberite cluster:"
$labelCluster1.Location = New-Object System.Drawing.Point(20, 130)
$labelCluster1.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelCluster1)
$labelCluster1.Enabled = $false

$comboCluster1 = New-Object System.Windows.Forms.ComboBox
$comboCluster1.Location = New-Object System.Drawing.Point(140, 128)
$comboCluster1.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($comboCluster1)
$comboCluster1.Enabled = $false

# Labela i ComboBox za hostove (puni se posle konekcije/konstrukcije)
$labelHost = New-Object System.Windows.Forms.Label
$labelHost.Text = "Izaberite host:"
$labelHost.Location = New-Object System.Drawing.Point(20, 170)
$labelHost.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelHost)
$labelHost.Enabled = $false

$comboHost = New-Object System.Windows.Forms.ComboBox
$comboHost.Location = New-Object System.Drawing.Point(140, 168)
$comboHost.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($comboHost)
$comboHost.Enabled = $false

# Labela i ComboBox za drugi cluster (koristi se kod opcije 4)
$labelCluster2 = New-Object System.Windows.Forms.Label
$labelCluster2.Text = "Izaberite ciljni cluster:"
$labelCluster2.Location = New-Object System.Drawing.Point(20, 210)
$labelCluster2.Size = New-Object System.Drawing.Size(120, 20)
$form.Controls.Add($labelCluster2)
$labelCluster2.Enabled = $false

$comboCluster2 = New-Object System.Windows.Forms.ComboBox
$comboCluster2.Location = New-Object System.Drawing.Point(140, 208)
$comboCluster2.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($comboCluster2)
$comboCluster2.Enabled = $false

# Labela i Textbox za unos VLAN ID
$labelVlan = New-Object System.Windows.Forms.Label
$labelVlan.Text = "VLAN ID:"
$labelVlan.Location = New-Object System.Drawing.Point(20, 250)
$labelVlan.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelVlan)
$labelVlan.Enabled = $false

$textVlan = New-Object System.Windows.Forms.TextBox
$textVlan.Location = New-Object System.Drawing.Point(140, 248)
$textVlan.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($textVlan)
$textVlan.Enabled = $false

# Dugme za izvršenje selektovane opcije
$buttonRun = New-Object System.Windows.Forms.Button
$buttonRun.Location = New-Object System.Drawing.Point(140, 280)
$buttonRun.Size = New-Object System.Drawing.Size(100, 30)
$buttonRun.Text = "Izvrši"
$buttonRun.Enabled = $false
$form.Controls.Add($buttonRun)

# Textbox za prikaz rezultata i logova
$textOutput = New-Object System.Windows.Forms.TextBox
$textOutput.Location = New-Object System.Drawing.Point(20, 320)
$textOutput.Size = New-Object System.Drawing.Size(540, 130)
$textOutput.Multiline = $true
$textOutput.ScrollBars = 'Vertical'
$textOutput.ReadOnly = $true
$form.Controls.Add($textOutput)

#
# Funkcije / Event handleri
#

# Pomoćna funkcija: update log
function Append-Output {
    param($msg)
    $textOutput.AppendText($msg + "`r`n")
    $textOutput.SelectionStart = $textOutput.Text.Length
    $textOutput.ScrollToCaret()
}

# Povezivanje i punjenje cluster liste
$buttonConnect.Add_Click({
    $textOutput.Clear()
    $labelStatus.Text = "Povezujem na vCenter: $($comboVCenter.SelectedItem)..."
    try {
        Connect-VIServer -Server $comboVCenter.SelectedItem -WarningAction SilentlyContinue | Out-Null
        $labelStatus.Text = "Uspešno povezano na $($comboVCenter.SelectedItem)"
