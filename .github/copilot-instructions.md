# AI Coding Agent Instructions for This Repo

## Overview
- **Purpose:** Collection of PowerShell scripts automating vSphere/vCenter tasks, audits, and reports; includes a small WinForms UI and a 3-step cluster config check pipeline.
- **Key Areas:**
  - CLI scripts in workspace root (e.g., reporting, patch checks, VLAN and datastore queries).
  - UI under [Vcenter_UI](Vcenter_UI) with tabbed Windows Forms.
  - Cluster configuration pipeline under [Cluster_Config_Check](Cluster_Config_Check).

## Dependencies & Environment
- **VMware.PowerCLI:** Most scripts require `Import-Module VMware.PowerCLI` and `Connect-VIServer`.
- **WinForms UI:** Uses `System.Windows.Forms` and `System.Drawing` ([Vcenter_UI/Glavni_UI_prozor.ps1](Vcenter_UI/Glavni_UI_prozor.ps1)).
- **DirectoryServices:** LDAP checks use .NET `DirectoryServices` ([LDAP_Provera.ps1](LDAP_Provera.ps1)).
- **Windows paths:** Scripts commonly read/write under `C:\temp`, `C:\Cluster_Config_Check\<date>`, or user profile paths.

## Core Workflows
- **vCenter connect/disconnect:**
  - Pattern: `Connect-VIServer -Server <host> -Credential (Get-Credential)` and `Disconnect-VIServer -Confirm:$false`.
  - Example: [Cluster_Config_Check/Get_Check_304Vlkan_prototip_1.ps1](Cluster_Config_Check/Get_Check_304Vlkan_prototip_1.ps1), [Cluster_List_VM_IPaddres_vlan.ps1](Cluster_List_VM_IPaddres_vlan.ps1).
- **Cluster Config Check (3-step):**
  - [Cluster_Config_Check/1_Get_Cluster_Config_Full.ps1](Cluster_Config_Check/1_Get_Cluster_Config_Full.ps1): Collects cluster/host network config; writes CSVs to `C:\Cluster_Config_Check/<datum>`.
  - [Cluster_Config_Check/2_Compare_New_Hosts_Full.ps1](Cluster_Config_Check/2_Compare_New_Hosts_Full.ps1): Compares new hosts vs. reference CSV.
  - [Cluster_Config_Check/3_Generate_HTML_Report.ps1](Cluster_Config_Check/3_Generate_HTML_Report.ps1): Produces HTML report (green OK, red differences).
  - Notes: See [Cluster_Config_Check/README_RDM_Cluster_Config_Check_Full_v2.txt](Cluster_Config_Check/README_RDM_Cluster_Config_Check_Full_v2.txt).
- **CSV reporting:** Use `Select-Object` with calculated properties; export with `Export-Csv -NoTypeInformation`.
  - Examples: [ESXi_Provera_verzije_patcha_v1_export_csv.ps1](ESXi_Provera_verzije_patcha_v1_export_csv.ps1), [Get_SRM_VM_Report.ps1](Get_SRM_VM_Report.ps1).
- **UI workflow:** [Vcenter_UI/Glavni_UI_prozor.ps1](Vcenter_UI/Glavni_UI_prozor.ps1) dot-sources tab setup scripts ([Vcenter_UI/Tab1Konekcija_cluster_funkcije.ps1](Vcenter_UI/Tab1Konekcija_cluster_funkcije.ps1), [Vcenter_UI/Tab2_Dodavanje_Vlana.ps1](Vcenter_UI/Tab2_Dodavanje_Vlana.ps1)) and calls `Setup-Tab1`, `Setup-Tab2`. Globals share state (e.g., `$global:vCenterConnection`, `$global:ClusterList`).

## Conventions & Patterns
- **Filtering:** Exclusions via arrays and `Where-Object` (e.g., `$vmExclusions`, `$clusterExclusions`) as in [Cluster_Config_Check/Get_Check_304Vlkan_prototip_1.ps1](Cluster_Config_Check/Get_Check_304Vlkan_prototip_1.ps1).
- **Selection:** `Select-Object` with named/calculated properties common in reports (e.g., `@{Name='VLAN';Expression={...}}`).
- **Enumerations:** Iterate clusters → VMs → network adapters/datastores; prefer server-scoped cmdlets (e.g., `Get-Cluster -Server $connection`).
- **Output:** Console via `Write-Host` for human-readable summaries; CSV for structured outputs under fixed Windows paths.
- **UI composition:** Tab setup functions add controls and hook events; dot-sourced scripts must be loadable via paths configured in the UI host script.

## Integration Points
- **vCenter/vSphere:** `Connect-VIServer`, `Get-Cluster`, `Get-VM`, `Get-VMHost`, `Get-Datastore`, `Get-NetworkAdapter`, `Get-VirtualPortGroup` appear throughout.
- **Stats & health:** `Get-Stat` for host metrics (CPU/mem/storage) in [ESXi_Provera_verzije_patcha_v1_export_csv.ps1](ESXi_Provera_verzije_patcha_v1_export_csv.ps1).
- **LDAP:** `DirectoryServices.DirectoryEntry` and `DirectorySearcher` in [LDAP_Provera.ps1](LDAP_Provera.ps1).

## Practical Examples
- **VLAN scan (304):** [Cluster_Config_Check/Get_Check_304Vlkan_prototip_1.ps1](Cluster_Config_Check/Get_Check_304Vlkan_prototip_1.ps1) filters clusters/VMs and checks port group `VlanId`.
- **VM + VLAN report:** [Cluster_List_VM_IPaddres_vlan.ps1](Cluster_List_VM_IPaddres_vlan.ps1) combines `Get-VMGuest` IP with port group VLAN.
- **Host/cluster inventory:** [DatastoreVM.ps1](DatastoreVM.ps1) enumerates clusters → datastores → VMs; disconnects at end.

## Notes for Editing/Extending
- Maintain existing connection and output patterns; scripts often assume local paths and direct `Write-Host` output.
- Some scripts use inline credentials; others use `Get-Credential`. Match the local pattern within each directory/script unless directed to standardize.
- When touching UI code, keep `Setup-Tab*` signatures and global sharing consistent; avoid renaming globals used across tabs.

---
Questions or missing workflows? If there are other build/run conventions or paths I didn’t capture (e.g., custom report folders or scheduler setups), point me to them and I’ll refine this document.