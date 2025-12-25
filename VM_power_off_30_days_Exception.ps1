Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false >/dev/null 2>&1
Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -Confirm:$false >/dev/null 2>&1
$vCenter = $args[0]
Connect-VIServer $vCenter -User nagios@vsphere.local -Password beograd011 *> $null


# Calculate limit date (30 days ago)
$limitDate = (Get-Date).AddDays(-30)

# Get All VMs
$poweredoffVM = Get-VM | Where-Object { $_.PowerState -eq "PoweredOff" -and $_.Name -notin @("DMSINTEG4", "mqway4prod", "DMSINDEX", "PRINTTERM4", "DMSINTEG", "LNAPPLICATION1", "DMSCAPTIVE", "DMSINTEG6", "rbrscognos11", "DMSAPP", "DMSNLB1", "FXTRADE", "DMSPROXY", "CASDMSOOS", "DMSINTEG5", "HOATMDEPLOYDB", "HOEBANKEBB", "HODPS", "DMSCAPT1", "DMSBACKUP", "HORBRSMQ1", "DMSOOS", "HODPS1", "pkafkacon1", "infoportalfe1prod", "HOAVAYA_AES", "HOAVAYA_SYSMNGR", "Honiceuptivity", "HOININCICDB", "DRRBRSPGAPP", "DRRBRSPGARR", "HOPLPTEST", "Rbrsdp02ho", "Drrssoaapp4", "splunksyslog1", "pkafkacon2", "posbe1", "posbe2", "loxappprod", "prhsso1", "rssoaapp1way4", "infoportalbe1prod", "prhsso2", "vmwfappgold_backup030522",
	"vmwfhgold", "vmxenappgold_250323", "vmwfhgold_bkp11.11.22", "vmxenappgold_28.11.23", "vmxenappgold") }

# Powered VMs 30 days or more
$filterVM = $poweredoffVM | Where-Object { $_.ExtensionData.Runtime.PowerStateChangeTime -lt $limitDate }

# Check powered off VMs
if ($filterVM.Count -eq 0) {

    Write-Output "No VMs powered off 30 days or more."
    exit 0
} else {

    Write-Output "Powered off VMs: $filterVM"
    exit 1
}

# Odjavljivanje sa vCenter servera
Disconnect-VIServer -Server $vCenter -Confirm:$false
