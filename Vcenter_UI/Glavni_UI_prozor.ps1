Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Globalne varijable za deljenje podataka i objekte kontrola
$global:vCenterConnection = $null
$global:ClusterList = @()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Modularni vCenter menadžer"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"

$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(760, 540)
$tabControl.Location = New-Object System.Drawing.Point(15, 15)

$tabPage1 = New-Object System.Windows.Forms.TabPage("Povezivanje")
$tabPage2 = New-Object System.Windows.Forms.TabPage("Dodavanje VLAN-ova")
$tabPage3 = New-Object System.Windows.Forms.TabPage("Izvestaji")

$tabControl.TabPages.Add($tabPage1)
$tabControl.TabPages.Add($tabPage2)
$tabControl.TabPages.Add($tabPage3)

$form.Controls.Add($tabControl)

# Učitaj skripte koje dopunjuju tabove
. "C:\Users\yuasubr\Documents\PowershellScript\Vcenter_UI\Tab1Konekcija_cluster_funkcije.ps1"    # Očekuje $tabPage1 kao parametar
. "C:\Users\yuasubr\Documents\PowershellScript\Vcenter_UI\Tab2_Dodavanje_Vlana.ps1"      # Očekuje $tabPage2 kao parametar

# Pokreni setup funkcije koje dodaju kontrole u tabove
Setup-Tab1 -TabPage $tabPage1
Setup-Tab2 -TabPage $tabPage2

$form.ShowDialog()
