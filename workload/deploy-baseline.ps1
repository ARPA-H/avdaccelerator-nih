$avdVmLocalUserPassword = Read-Host -Prompt "Local user password" -AsSecureString
$avdDomainJoinUserPassword = Read-Host -Prompt "Domain join password" -AsSecureString
New-AzSubscriptionDeployment `
  -TemplateFile workload/bicep/deploy-baseline.bicep `
  -TemplateParameterFile workload/bicep/parameters/deploy-baseline-parameters-example.json `
  -avdWorkloadSubsId "5e59332d-6f87-41b0-bf2f-a9a9ee67c581" `
  -deploymentPrefix "<deploymentPrefix>" `
  -avdVmLocalUserName "avd.admin" `
  -avdVmLocalUserPassword $avdVmLocalUserPassword `
  -avdIdentityServiceProvider "<IdentityServiceProvider>" `
  -avdIdentityDomainName "<domainJoinUserName>" `
  -avdDomainJoinUserName "<domainJoinUserName>"  `
  -avdDomainJoinUserPassword $avdDomainJoinUserPassword `
  -existingHubVnetResourceId "<hubVnetResourceId>"  `
  -customDnsIps "<customDNSservers>"  `
  -avdEnterpriseAppObjectId "<wvdAppObjectId>" `
  -avdVnetPrivateDnsZone $true `
  -avdVnetPrivateDnsZoneFilesId "<PrivateDnsZoneFilesId>" `
  -avdVnetPrivateDnsZoneKeyvaultId "<PrivateDnsZoneKeyvaultId>" `
  -avdDeployMonitoring $true `
  -deployAlaWorkspace $true `
  -Location "eastus"