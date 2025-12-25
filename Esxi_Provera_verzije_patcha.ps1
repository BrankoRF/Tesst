#Login to vcenter

$vcenter = "drvcenter"

#Select Cluster
#$cluster_name = "HO-Citrix"

#Insert expected build
$expected_build = "21930508"

Connect-VIServer $vcenter 

#Get-Cluster $cluster_name | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "DR-Citrix" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "DR-Core" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "DR-DMZ1" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "DR-Prod" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-Prod-Lin" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-Prod-Win" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-Prod-Win-2" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-Remote" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-SQL" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-Test-Lin" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-Test-Win" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}

Get-Cluster "HO-Tokens" | Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}



#Number of hosts with No


#Get-VMHost | Select @{Label = "Host"; Expression = {$_.Name}} , @{Label = "ESX Version"; Expression = {$_.version}}, @{Label = "ESX Build" ; Expression = {$_.build}} , @{Label = "Build Match" ; Expression = {if($_.build -eq $expected_build){"Yes"} else{"No"}}}
