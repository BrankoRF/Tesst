README_RDM_Cluster_Config_Check_Full_v2.txt
--------------------------------------------------
Ovaj paket sadrži PowerCLI skripte za proveru konfiguracije vSphere klastera i hostova.

1. 1_Get_Cluster_Config_Full.ps1
   - Prikuplja konfiguraciju klastera, vSwitch-eva, port grupa, VMkernel adaptera i licenci.
   - Rezultat se snima u CSV fajl unutar C:\Cluster_Config_Check\<datum>.

2. 2_Compare_New_Hosts_Full.ps1
   - Upoređuje konfiguraciju novih hostova sa referentnom konfiguracijom iz CSV fajla.

3. 3_Generate_HTML_Report.ps1
   - Generiše HTML izveštaj sa vizuelnim prikazom (zeleno = OK, crveno = razlika).

Svi skripte koriste Get-Credential za autentifikaciju prema vCenter serveru.
Primer:
   $cred = Get-Credential
   Connect-VIServer -Server vcenter01.lab.local -Credential $cred

--------------------------------------------------
Autor: Branko.S
Datum: 2025-10-25
