function Setup-Tab2 {
    param([System.Windows.Forms.TabPage]$TabPage)

    ### Label i ComboBox za izbor tipa resursa (Cluster ili Host)
    $labelResourceType = New-Object System.Windows.Forms.Label
    $labelResourceType.Text = "Izaberite tip resursa:"
    $labelResourceType.Location = New-Object System.Drawing.Point(20, 20)
    $labelResourceType.Size = New-Object System.Drawing.Size(130, 20)
    $TabPage.Controls.Add($labelResourceType)

    $comboResourceType = New-Object System.Windows.Forms.ComboBox
    $comboResourceType.Location = New-Object System.Drawing.Point(160, 18)
    $comboResourceType.Size = New-Object System.Drawing.Size(200, 20)
    $comboResourceType.Items.AddRange(@("Cluster", "Host"))
    $comboResourceType.DropDownStyle = 'DropDownList'
    $comboResourceType.SelectedIndex = 0
    $TabPage.Controls.Add($comboResourceType)

    ### ComboBox za prikaz cluster-a ili host-a
    $comboResourceItems = New-Object System.Windows.Forms.ComboBox
    $comboResourceItems.Location = New-Object System.Drawing.Point(160, 58)
    $comboResourceItems.Size = New-Object System.Drawing.Size(300, 20)
    $comboResourceItems.Enabled = $false
    $TabPage.Controls.Add($comboResourceItems)

    ### Labela i TextBox za unos VLAN ID
    $labelVlan = New-Object System.Windows.Forms.Label
    $labelVlan.Text = "VLAN ID:"
    $labelVlan.Location = New-Object System.Drawing.Point(20, 100)
    $labelVlan.Size = New-Object System.Drawing.Size(100, 20)
    $labelVlan.Enabled = $false
    $TabPage.Controls.Add($labelVlan)

    $textVlan = New-Object System.Windows.Forms.TextBox
    $textVlan.Location = New-Object System.Drawing.Point(160, 98)
    $textVlan.Size = New-Object System.Drawing.Size(100, 20)
    $textVlan.Enabled = $false
    $TabPage.Controls.Add($textVlan)

    ### Labela i ComboBox za izbor akcije
    $labelOption = New-Object System.Windows.Forms.Label
    $labelOption.Text = "Izaberite opciju:"
    $labelOption.Location = New-Object System.Drawing.Point(20, 140)
    $labelOption.Size = New-Object System.Drawing.Size(100, 20)
    $TabPage.Controls.Add($labelOption)

    $comboOption = New-Object System.Windows.Forms.ComboBox
    $comboOption.Location = New-Object System.Drawing.Point(160, 138)
    $comboOption.Size = New-Object System.Drawing.Size(230, 20)
    $comboOption.Items.AddRange(@(
        'Add VLAN to cluster',
        'Add VLAN to host',
        'Add cluster VLANs to host',
        'Add cluster VLANs to another cluster'
    ))
    $comboOption.Enabled = $false
    $TabPage.Controls.Add($comboOption)

    ### Dugme za izvršenje
    $buttonRun = New-Object System.Windows.Forms.Button
    $buttonRun.Text = "Izvrši"
    $buttonRun.Location = New-Object System.Drawing.Point(160, 180)
    $buttonRun.Size = New-Object System.Drawing.Size(100, 30)
    $buttonRun.Enabled = $false
    $TabPage.Controls.Add($buttonRun)

    ### Tekst polje za prikaz logova
    $textOutput = New-Object System.Windows.Forms.TextBox
    $textOutput.Location = New-Object System.Drawing.Point(20, 220)
    $textOutput.Size = New-Object System.Drawing.Size(540, 280)
    $textOutput.Multiline = $true
    $textOutput.ScrollBars = 'Vertical'
    $textOutput.ReadOnly = $true
    $TabPage.Controls.Add($textOutput)

    # Postavljanje globalnih referenci na kontrole
    $global:Tab2_ComboResourceType = $comboResourceType
    $global:Tab2_ComboResourceItems = $comboResourceItems
    $global:Tab2_LabelVlan = $labelVlan
    $global:Tab2_TextVlan = $textVlan
    $global:Tab2_ComboOption = $comboOption
    $global:Tab2_ButtonRun = $buttonRun
    $global:Tab2_TextOutput = $textOutput

    function AppendOutput([string]$msg) {
        $global:Tab2_TextOutput.AppendText("$msg`r`n")
        $global:Tab2_TextOutput.SelectionStart = $global:Tab2_TextOutput.Text.Length
        $global:Tab2_TextOutput.ScrollToCaret()
    }

    # Event: Pri ulasku u tab
    $TabPage.Add_Enter({
        # Reset kontrola na početne vrednosti
        $global:Tab2_ComboResourceType.SelectedIndex = 0
        $global:Tab2_ComboResourceItems.Items.Clear()
        if ($global:ClusterList.Count -gt 0) {
            foreach ($item in $global:ClusterList) {
                $global:Tab2_ComboResourceItems.Items.Add($item)
            }
            $global:Tab2_ComboResourceItems.Enabled = $true
        }
        else {
            $global:Tab2_ComboResourceItems.Enabled = $false
        }
        $global:Tab2_ComboOption.Enabled = $global:Tab2_ComboResourceItems.Enabled
        $global:Tab2_ButtonRun.Enabled = $false
        $global:Tab2_LabelVlan.Enabled = $false
        $global:Tab2_TextVlan.Enabled = $false
        AppendOutput "Dobrodošli u tab za VLAN operacije."
    })

    # Event: Promena tipa resursa (Cluster / Host)
    $global:Tab2_ComboResourceType.Add_SelectedIndexChanged({
        if (-not $global:vCenterConnection) {
            AppendOutput "Niste povezani na vCenter. Osvežavanje liste nije moguće."
            $global:Tab2_ComboResourceItems.Enabled = $false
            return
        }

        $global:Tab2_ComboResourceItems.Items.Clear()

        if ($global:Tab2_ComboResourceType.SelectedItem -eq "Cluster") {
            foreach ($clusterName in $global:ClusterList) {
                $global:Tab2_ComboResourceItems.Items.Add($clusterName)
            }
            $global:Tab2_ComboResourceItems.Enabled = $true
        }
        elseif ($global:Tab2_ComboResourceType.SelectedItem -eq "Host") {
            try {
                $hosts = Get-VMHost -Server $global:vCenterConnection | Sort-Object Name
                foreach ($host in $hosts) {
                    $global:Tab2_ComboResourceItems.Items.Add($host.Name)
                }
                $global:Tab2_ComboResourceItems.Enabled = $global:Tab2_ComboResourceItems.Items.Count -gt 0
            }
            catch {
                AppendOutput "Greška prilikom dohvata hostova: $_"
                $global:Tab2_ComboResourceItems.Enabled = $false
            }
        }

        $global:Tab2_ComboOption.Enabled = $global:Tab2_ComboResourceItems.Enabled
        $global:Tab2_ButtonRun.Enabled = $false
    })

    # Event: Promena izabrane stavke u resourceItems combo
    $global:Tab2_ComboResourceItems.Add_SelectedIndexChanged({
        $global:Tab2_ButtonRun.Enabled = ($global:Tab2_ComboResourceItems.SelectedItem -ne $null) -and ($global:Tab2_ComboOption.SelectedItem -ne $null)
    })

    # Event: Promena izabrane opcije
    $global:Tab2_ComboOption.Add_SelectedIndexChanged({
        $enabledVlan = $false
        switch ($global:Tab2_ComboOption.SelectedItem) {
            'Add VLAN to cluster' { $enabledVlan = $true }
            'Add VLAN to host' { $enabledVlan = $true }
        }
        $global:Tab2_LabelVlan.Enabled = $enabledVlan
        $global:Tab2_TextVlan.Enabled = $enabledVlan

        $global:Tab2_ButtonRun.Enabled = ($global:Tab2_ComboResourceItems.SelectedItem -ne $null) -and ($global:Tab2_ComboOption.SelectedItem -ne $null)
    })

    # Event: Klik na dugme Izvrši
    $global:Tab2_ButtonRun.Add_Click({
        $global:Tab2_TextOutput.Clear()

        if (-not $global:vCenterConnection) {
            AppendOutput "Niste povezani na vCenter!"
            return
        }

        if (-not $global:Tab2_ComboResourceItems.SelectedItem) {
            AppendOutput "Izaberite resurs (cluster ili host)!"
            return
        }

        if (-not $global:Tab2_ComboOption.SelectedItem) {
            AppendOutput "Izaberite opciju!"
            return
        }

        if (($global:Tab2_ComboOption.SelectedItem -in @('Add VLAN to cluster','Add VLAN to host')) -and [string]::IsNullOrWhiteSpace($global:Tab2_TextVlan.Text)) {
            AppendOutput "Unesite validan VLAN ID!"
            return
        }

        $resourceName = $global:Tab2_ComboResourceItems.SelectedItem
        $resourceType = $global:Tab2_ComboResourceType.SelectedItem
        $option = $global:Tab2_ComboOption.SelectedItem

        AppendOutput "Izabrana akcija: $option"
        AppendOutput "Na ${resourceType}: $resourceName"

        try {
            switch ($option) {
                'Add VLAN to cluster' {
                    $vid = [int]$global:Tab2_TextVlan.Text
                    AppendOutput "Dodajem VLAN $vid u cluster $resourceName ..."
                    # Ovde pozvati PowerCLI komande kao što ove (primer):
                    # Get-Cluster -Name $resourceName -Server $global:vCenterConnection | 
                    # Get-VMHost | Get-VirtualSwitch -Name vSwitch0 | 
                    # New-VirtualPortGroup -Name ("VLAN$vid") -VlanId $vid
                }
                'Add VLAN to host' {
                    $vid = [int]$global:Tab2_TextVlan.Text
                    AppendOutput "Dodajem VLAN $vid na host $resourceName ..."
                    # Ovde pozvati PowerCLI komande kao što ove (primer):
                    # Get-VMHost -Name $resourceName -Server $global:vCenterConnection | 
                    # Get-VirtualSwitch -Name vSwitch0 | 
                    # New-VirtualPortGroup -Name ("VLAN$vid") -VlanId $vid
                }
                'Add cluster VLANs to host' {
                    AppendOutput "Implementacija kopiranja VLAN-ova između hostova"
                }
                'Add cluster VLANs to another cluster' {
                    AppendOutput "Implementacija kopiranja VLAN-ova između cluster-a"
                }
                default {
                    AppendOutput "Nepoznata opcija."
                }
            }
        }
        catch {
            AppendOutput "Greška pri izvršenju: $_"
        }
    })
}
