# Učitaj potrebne .NET assembly za Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Funkcija za povezivanje na vCenter i dohvatanje clustera
function Get-ClustersFromVCenter {
    param(
        [string]$vCenterServer,
        [System.Management.Automation.PSCredential]$Credential
    )
    try {
        $viserver = Connect-VIServer -Server $vCenterServer -Credential $Credential -ErrorAction Stop
        $clusters = Get-Cluster -Server $viserver | Sort-Object Name
        Disconnect-VIServer -Server $viserver -Confirm:$false
        return $clusters
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Neuspešna konekcija na vCenter: $_", "Greška", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return $null
    }
}

# Glavni GUI form
$form = New-Object System.Windows.Forms.Form
$form.Text = "vSphere Cluster Manager"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = "CenterScreen"

# Labela za vCenter server
$labelVCenter = New-Object System.Windows.Forms.Label
$labelVCenter.Location = New-Object System.Drawing.Point(10,20)
$labelVCenter.Size = New-Object System.Drawing.Size(120,20)
$labelVCenter.Text = "vCenter server:"
$form.Controls.Add($labelVCenter)

# Textbox za unos vCenter servera
$textBoxVCenter = New-Object System.Windows.Forms.TextBox
$textBoxVCenter.Location = New-Object System.Drawing.Point(140,18)
$textBoxVCenter.Size = New-Object System.Drawing.Size(220,20)
$form.Controls.Add($textBoxVCenter)

# Dugme za konekciju
$buttonConnect = New-Object System.Windows.Forms.Button
$buttonConnect.Location = New-Object System.Drawing.Point(140,50)
$buttonConnect.Size = New-Object System.Drawing.Size(100,23)
$buttonConnect.Text = "Poveži se"
$form.Controls.Add($buttonConnect)

# Labela za izbor clustera
$labelCluster = New-Object System.Windows.Forms.Label
$labelCluster.Location = New-Object System.Drawing.Point(10,90)
$labelCluster.Size = New-Object System.Drawing.Size(120,20)
$labelCluster.Text = "Izaberite cluster:"
$form.Controls.Add($labelCluster)

# ComboBox za listu cluster-a
$comboBoxClusters = New-Object System.Windows.Forms.ComboBox
$comboBoxClusters.Location = New-Object System.Drawing.Point(140,88)
$comboBoxClusters.Size = New-Object System.Drawing.Size(220,20)
$comboBoxClusters.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBoxClusters.Enabled = $false
$form.Controls.Add($comboBoxClusters)

# Labela za izbor opcije
$labelOptions = New-Object System.Windows.Forms.Label
$labelOptions.Location = New-Object System.Drawing.Point(10,130)
$labelOptions.Size = New-Object System.Drawing.Size(120,20)
$labelOptions.Text = "Opcije:"
$form.Controls.Add($labelOptions)

# ComboBox za opcije vezane za cluster
$comboBoxOptions = New-Object System.Windows.Forms.ComboBox
$comboBoxOptions.Location = New-Object System.Drawing.Point(140,128)
$comboBoxOptions.Size = New-Object System.Drawing.Size(220,20)
$comboBoxOptions.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBoxOptions.Enabled = $false
$form.Controls.Add($comboBoxOptions)

# Dugme za izvršenje izabrane opcije
$buttonExecute = New-Object System.Windows.Forms.Button
$buttonExecute.Location = New-Object System.Drawing.Point(140,170)
$buttonExecute.Size = New-Object System.Drawing.Size(100,23)
$buttonExecute.Text = "Izvrši"
$buttonExecute.Enabled = $false
$form.Controls.Add($buttonExecute)

# Tekst box za prikaz rezultata
$textBoxOutput = New-Object System.Windows.Forms.TextBox
$textBoxOutput.Location = New-Object System.Drawing.Point(10,210)
$textBoxOutput.Size = New-Object System.Drawing.Size(360,100)
$textBoxOutput.Multiline = $true
$textBoxOutput.ScrollBars = "Vertical"
$textBoxOutput.ReadOnly = $true
$form.Controls.Add($textBoxOutput)

# Opcije koje nudimo korisniku za izabrani cluster
$clusterOptions = @(
    "Izlistaj hostove i njihove MAC adrese",
    "Prikaži stanje clustera",
    "Pokreni DRS preporuke"
	"Izlistaj virtualne mašine na clusteru"
	"Proveri VM sa RDM diskovima"
)

# Popuni comboBoxOptions
$comboBoxOptions.Items.AddRange($clusterOptions)

# Event handler za dugme Poveži se
$buttonConnect.Add_Click({
    $textBoxOutput.Clear()
    $vCenter = $textBoxVCenter.Text.Trim()
    if (-not $vCenter) {
        [System.Windows.Forms.MessageBox]::Show("Unesite vCenter server!", "Upozorenje", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Traži korisničke kredencijale
    $cred = Get-Credential -Message "Unesite korisničko ime i lozinku za $vCenter"

    $clusters = Get-ClustersFromVCenter -vCenterServer $vCenter -Credential $cred

    if ($clusters -and $clusters.Count -gt 0) {
        $comboBoxClusters.Items.Clear()
        foreach ($c in $clusters) {
            $comboBoxClusters.Items.Add($c.Name)
        }
        $comboBoxClusters.Enabled = $true
        $comboBoxOptions.Enabled = $true
        $buttonExecute.Enabled = $true
        $textBoxOutput.AppendText("Uspešno povezano na $vCenter`r`n")
    } else {
        $textBoxOutput.AppendText("Nema dostupnih cluster-a ili neuspešna konekcija.`r`n")
        $comboBoxClusters.Enabled = $false
        $comboBoxOptions.Enabled = $false
        $buttonExecute.Enabled = $false
    }
})

# Funkcija za izvršavanje izabrane opcije
function Execute-ClusterOption {
    param(
        [string]$vCenter,
        [System.Management.Automation.PSCredential]$Credential,
        [string]$clusterName,
        [string]$option
    )

    # Ponovo se povezujemo na vCenter da bismo izvršili komande
    $viserver = Connect-VIServer -Server $vCenter -Credential $Credential -ErrorAction Stop

    switch ($option) {
        "Izlistaj hostove i njihove MAC adrese" {
            $output = ""
            $hosts = Get-Cluster -Name $clusterName -Server $viserver | Get-VMHost
			foreach ($singleHost in $hosts) {
			$nics = $singleHost | Get-VMHostNetworkAdapter
			foreach ($nic in $nics) {
			$output += "Host: $($singleHost.Name), NIC: $($nic.Name), MAC: $($nic.Mac)`r`n"
			}
		}
            $textBoxOutput.AppendText($output)
        }
        "Prikaži stanje clustera" {
            $cluster = Get-Cluster -Name $clusterName -Server $viserver
            $textBoxOutput.AppendText("Cluster '$clusterName' HAEnabled: $($cluster.HAEnabled), DrsEnabled: $($cluster.DrsEnabled)`r`n")
        }
        "Pokreni DRS preporuke" {
            # Primer pokretanja DRS preporuka (simulacija)
            $textBoxOutput.AppendText("Pokrećem DRS preporuke za cluster '$clusterName'...`r`n")
            # Ovde bi išao pravi poziv, npr.:
            # Invoke-DrsRecommendation -Cluster $cluster
            $textBoxOutput.AppendText("DRS preporuke su pokrenute.`r`n")
        }
        default {
            $textBoxOutput.AppendText("Nepoznata opcija.`r`n")
        }
		# Listanje virtualnih masina
		"Izlistaj virtualne mašine na clusteru" {
            $output = ""
            $vms = Get-Cluster -Name $clusterName -Server $viserver | Get-VM | Sort-Object Name
            foreach ($vm in $vms) {
                $output += "VM: $($vm.Name), PowerState: $($vm.PowerState), Guest OS: $($vm.Guest.OSFullName)`r`n"
            }
            if (-not $output) {
                $output = "Nema virtualnih mašina na clusteru '$clusterName'.`r`n"
            }
            $textBoxOutput.AppendText($output)
        }
        default {
            $textBoxOutput.AppendText("Nepoznata opcija.`r`n")
        }
		# Listanje RDM diskova virtualnih masina
		"Proveri VM sa RDM diskovima" {
    $output = ""
    $vms = Get-Cluster -Name $clusterName -Server $viserver | Get-VM | Sort-Object Name
    foreach ($vm in $vms) {
        $output += "Proveravam VM: $($vm.Name)`r`n"
        $hardDisks = Get-HardDisk -VM $vm
        foreach ($disk in $hardDisks) {
            if ($disk.ExtensionData.Backing.GetType().Name -eq "VirtualDiskRawDiskMappingVer1BackingInfo") {
                # Ukloni prvih 10 i zadnjih 12 karaktera iz LUN UUID-a, ostavljajući 32 karaktera
                $lunUuid = $disk.ExtensionData.Backing.LunUuid
                $cleanedLunUuid = $lunUuid.Substring(10, 32) # Uzmi 32 karaktera počevši od 10. karaktera

                $output += "  Disk: $($disk.Name)`r`n"
                $output += "    Kapacitet (GB): $($disk.CapacityGB)`r`n"
                $output += "    DeviceName: $($disk.ExtensionData.DeviceName)`r`n"
                $output += "    CompatibilityMode: $($disk.ExtensionData.Backing.CompatibilityMode)`r`n"
                $output += "    LunUuid (čist): $cleanedLunUuid`r`n"
            }
        }
    }
    if (-not $output) {
        $output = "Nema VM sa RDM diskovima na clusteru '$clusterName'.`r`n"
    }
    $textBoxOutput.AppendText($output)
	}
    }

    Disconnect-VIServer -Server $viserver -Confirm:$false
}

# Čuvamo kredencijale i vCenter server globalno za kasniju upotrebu
$global:vCenterGlobal = $null
$global:CredentialGlobal = $null

# Izmena event handlera za konekciju da sačuva kredencijale
$buttonConnect.Add_Click({
    $vCenter = $textBoxVCenter.Text.Trim()
    if (-not $vCenter) { return }
    $global:vCenterGlobal = $vCenter
    $global:CredentialGlobal = Get-Credential -Message "Unesite korisničko ime i lozinku za $vCenter"
    $clusters = Get-ClustersFromVCenter -vCenterServer $vCenter -Credential $global:CredentialGlobal
    if ($clusters -and $clusters.Count -gt 0) {
        $comboBoxClusters.Items.Clear()
        foreach ($c in $clusters) {
            $comboBoxClusters.Items.Add($c.Name)
        }
        $comboBoxClusters.Enabled = $true
        $comboBoxOptions.Enabled = $true
        $buttonExecute.Enabled = $true
        $textBoxOutput.Clear()
        $textBoxOutput.AppendText("Uspešno povezano na $vCenter`r`n")
    } else {
        $textBoxOutput.Clear()
        $textBoxOutput.AppendText("Nema dostupnih cluster-a ili neuspešna konekcija.`r`n")
        $comboBoxClusters.Enabled = $false
        $comboBoxOptions.Enabled = $false
        $buttonExecute.Enabled = $false
    }
})

# Event handler za dugme Izvrši
$buttonExecute.Add_Click({
    if (-not $comboBoxClusters.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Izaberite cluster!", "Upozorenje", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    if (-not $comboBoxOptions.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Izaberite opciju!", "Upozorenje", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    $textBoxOutput.Clear()
    Execute-ClusterOption -vCenter $global:vCenterGlobal -Credential $global:CredentialGlobal -clusterName $comboBoxClusters.SelectedItem -option $comboBoxOptions.SelectedItem
})

# Prikaz forme
$form.Topmost = $true
[void]$form.ShowDialog()
