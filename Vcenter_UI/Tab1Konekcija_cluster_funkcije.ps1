Setup-Tab2 -TabPage $tabPage2
function Setup-Tab1 {
    param([System.Windows.Forms.TabPage]$TabPage)

    $labelVCenter = New-Object System.Windows.Forms.Label
    $labelVCenter.Text = "Unesite vCenter adresu:"
    $labelVCenter.Location = New-Object System.Drawing.Point(20, 20)
    $labelVCenter.Size = New-Object System.Drawing.Size(130, 20)
    $TabPage.Controls.Add($labelVCenter)

    $textVCenter = New-Object System.Windows.Forms.TextBox
    $textVCenter.Location = New-Object System.Drawing.Point(160, 18)
    $textVCenter.Size = New-Object System.Drawing.Size(280, 20)
    $TabPage.Controls.Add($textVCenter)

    $buttonConnect = New-Object System.Windows.Forms.Button
    $buttonConnect.Text = "Poveži se"
    $buttonConnect.Location = New-Object System.Drawing.Point(460, 16)
    $buttonConnect.Size = New-Object System.Drawing.Size(100, 25)
    $TabPage.Controls.Add($buttonConnect)

    $labelStatus = New-Object System.Windows.Forms.Label
    $labelStatus.Text = "Status veze: Nije povezano"
    $labelStatus.Location = New-Object System.Drawing.Point(20, 50)
    $labelStatus.Size = New-Object System.Drawing.Size(540, 20)
    $TabPage.Controls.Add($labelStatus)

    $comboClusters = New-Object System.Windows.Forms.ComboBox
    $comboClusters.Location = New-Object System.Drawing.Point(160, 90)
    $comboClusters.Size = New-Object System.Drawing.Size(280, 20)
    $comboClusters.Enabled = $false
    $TabPage.Controls.Add($comboClusters)

    $labelClusters = New-Object System.Windows.Forms.Label
    $labelClusters.Text = "Izaberite cluster:"
    $labelClusters.Location = New-Object System.Drawing.Point(20, 92)
    $labelClusters.Size = New-Object System.Drawing.Size(130, 20)
    $TabPage.Controls.Add($labelClusters)

    # Postavljamo globalne reference na kontrole za pristup izvan funkcije
    $global:Tab1_textVCenter = $textVCenter
    $global:Tab1_buttonConnect = $buttonConnect
    $global:Tab1_labelStatus = $labelStatus
    $global:Tab1_comboClusters = $comboClusters

    $buttonConnect.Add_Click({
        $global:Tab1_labelStatus.Text = "Povezivanje na $($global:Tab1_textVCenter.Text)..."

        if ([string]::IsNullOrWhiteSpace($global:Tab1_textVCenter.Text)) {
            $global:Tab1_labelStatus.Text = "Unesite validnu vCenter adresu."
            return
        }

        try {
            # Otvara se standardni credential prompt
            $cred = Get-Credential -Message "Unesite korisničko ime i lozinku za $($global:Tab1_textVCenter.Text)"

            $global:vCenterConnection = Connect-VIServer -Server $global:Tab1_textVCenter.Text -Credential $cred -WarningAction Stop
            $global:Tab1_labelStatus.Text = "Uspešno povezano na $($global:Tab1_textVCenter.Text)"

            $clusters = Get-Cluster -Server $global:vCenterConnection | Sort-Object Name
            $global:ClusterList = $clusters.Name

            $global:Tab1_comboClusters.Items.Clear()
            foreach ($c in $clusters) {
                $global:Tab1_comboClusters.Items.Add($c.Name)
            }
            $global:Tab1_comboClusters.Enabled = $global:Tab1_comboClusters.Items.Count -gt 0

            # Omogućimo unos u tab2 ako je već kreiran (ukoliko će tab2 koristiti)
            if ($global:Tab2_ComboCluster -ne $null) {
                $global:Tab2_ComboCluster.Items.Clear()
                foreach ($cName in $global:ClusterList) {
                    $global:Tab2_ComboCluster.Items.Add($cName)
                }
                $global:Tab2_ComboCluster.Enabled = $true
                # Možete omogućiti i dalje kontrole u Tab2 po potrebi
            }
        }
        catch {
            $global:Tab1_labelStatus.Text = "Konekcija neuspešna: $_"
            $global:Tab1_comboClusters.Items.Clear()
            $global:Tab1_comboClusters.Enabled = $false
            $global:vCenterConnection = $null
            $global:ClusterList = @()
        }
    })
}