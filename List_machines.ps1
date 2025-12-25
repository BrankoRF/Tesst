# Učitaj VMware PowerCLI modul
Import-Module VMware.PowerCLI

# Poveži se na vCenter Server
$vCenterServer = "drvcenter.rbj.co.yu"

$credential = Get-Credential

Connect-VIServer -Server $vCenterServer -Credential $credential

# Lista virtualnih mašina koje želite da proverite
$vmNames = @("CASDOCDBT","CRMSQLTEST1","CRMSQLTEST2","CRMSQLTEST3","DOCDBT","DRDBN1","DRDBS1","DRDBS3","DREBNSQL","DRRBJSQL","DRRLRSDB","drebnsql.dmz.raiffeisenbank.co.yu","DRPGAPP", "ebankppsql","ebanksqlrestore",
"EBANKTSQL", "EC1","EC2","EC3",       
"HOApiPmxTest",
"HOAPPPMX",  
"HOAPPPMXtest",
"HOARR1",    
"HOARR2",    
"HOATMDEPLOYB",
"hocmpapp1", 
"hocmpapp2", 
"hocrmapp1", 
"hocrmapp2", 
"hocrmapp3", 
"hocrmapp4", 
"hocrmtapp1",
"HODBN1",    
"HODBN2",    
"HODBPMX",  
"HODBPMXTEST",
"HODBS1",    
"HODBS2",    
"HODBS3",    
"HODBS4",    
"HODBS5",    
"HODMSSQLN1",
"HODMSSQLN2",
"HOEBANKREPORT",
"HOEBPWREPORTING",
"HOEBPCHATBO"T.dmz.raiffeisenbank.co.yu",
"HONICEUPTIVITY",
"HOPGAPPD",
"hopgappd",  
"HORBRSPGAPP1",
"HORBRSPGAPP2",
"horbrspgappt",
"HORBRSPGAppT2.rbj.co.yu",
"HORBRSPGARRT.rbj.co.yu",
"HORBRSPGARRT2.rbj.co.yu",
"HOREGSQL",
"HOREGSQLTEST",
"HORLRSSQLN1",
"HORLRSSQLN2",
"HOSELECTASQL1",
"HOSELECTASQL2",
"HOSELECTASQL3",
"HOSQLN3",
"HOSQLT5",
"HOSQLTEST1",
"HOSQLTEST2",
"HOTRESQL",
"HoTreAPPP",
"HoTreAppT",
"intsvct",
"KuanProd",
"KuanTest",
"MTCRMSQL1",
"MTCRMSQL2",
"MTCRMSQL3",
"NICEAPP",
"PHOBCAPP1",
"PHOBCAPP2",
"RBAARHIVACBS",
"RBAARHIVADBARH",
"RBAARHIVALOBO",
"rbaarhivanova",
"RBAARHIVAPPDLL",
"RbaArhivaWebApp,
"rbaarhivaws1",
"RBAArhivaWS16",
"RBAArhivaWS2",
"rbaarhivaws21",
"RBAArhivaWS24",
"RBAArhivaWS25",
"RBAArhivaWS3",
"RBAArhivaWS4",
"RBAArhivaWS5",
"RBAArhivaWS6",
"RBJEPOMAIN",
"RLRSSQLREPORT",
"RLRSSQLTEST",
"SQLTEST",   
"SQLTESTDR",
"TESTCRMSQL1",
"TESTCRMSQL2",
"TESTCRMSQL3",
"TESTSQLDR3",
"TESTSQLHO1",
"TESTSQLHO2",
"TESTSQLDR3",
)  # Zamenite sa stvarnim imenima vaših VM-ova

# Proveri na kojim hostovima se nalaze virtualne mašine sa spiska
foreach ($vmName in $vmNames) {
    $vm = Get-VM -Name $vmName -ErrorAction SilentlyContinue
    if ($vm) {
        $host = $vm.VMHost
        Write-Host "Virtual machine '$vmName' is located on host: $($host.Name)"
    } else {
        Write-Host "Virtual machine '$vmName' not found."
    }
}

# Diskonektuj se sa vCenter Server-a
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
