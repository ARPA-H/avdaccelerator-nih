targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@sys.description('AVD disk encryption set resource ID to enable server side encyption.')
param diskEncryptionSetResourceId string

@sys.description('AVD subnet ID.')
param subnetId string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('Virtual machine time zone.')
param timeZone string

@sys.description('General session host batch identifier')
param batchId int

@sys.description('AVD Session Host prefix.')
param namePrefix string

@sys.description('Resource Group name for the session hosts.')
param computeObjectsRgName string

@sys.description('Name of AVD service objects RG.')
param serviceObjectsRgName string

@sys.description('AVD workload subscription ID, multiple subscriptions scenario.')
param subscriptionId string

@sys.description('Quantity of session hosts to deploy.')
param count int

// @sys.description('Associate VMs with VMSS Flex group.')
// param useVmssFlex bool

// @sys.description('Max VMs per availability set.')
// param maxVmssFlexMembersCount int

@sys.description('The session host number to begin with for the deployment.')
param countIndex int

@sys.description('When true VMs are distributed across availability zones, when set to false, VMs will be deployed at regional level. (Default: true).')
param useAvailabilityZones bool

// @sys.description('VMSS flex name.')
// param vmssFlexNamePrefix string

@sys.description('The service providing domain services for Azure Virtual Desktop.')
param identityServiceProvider string

@sys.description('Enroll session hosts on Intune.')
param createIntuneEnrollment bool

@sys.description('This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool

@sys.description('Session host VM size.')
param vmSize string

@sys.description('Enables accelerated Networking on the session hosts.')
param enableAcceleratedNetworking bool

@sys.description('Specifies the securityType of the virtual machine. Must be TrustedLaunch or ConfidentialVM enable UefiSettings.')
param securityType string

@sys.description('Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. securityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool

@sys.description('Specifies whether virtual TPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  securityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool

@sys.description('OS disk type for session host.')
param diskType string

@sys.description('Optional. Define custom OS disk size if larger than image size.')
param customOsDiskSizeGB string = ''

@sys.description('Market Place OS image.')
param marketPlaceGalleryWindows object

@sys.description('Set to deploy image from Azure Compute Gallery.')
param useSharedImage bool

@sys.description('Source custom image ID.')
param avdImageTemplateDefinitionId string

// @sys.description('Local administrator username.')
// param vmLocalUserName string

@sys.description('Name of keyvault that contains credentials.')
param wrklKvName string

@sys.description('Identity domain name.')
param identityDomainName string

@sys.description('AVD session host domain join credentials.')
@secure()
param domainJoinUserName string

@sys.description('OU path to join AVd VMs.')
param sessionHostOuPath string

@sys.description('Application Security Group (ASG) for the session hosts.')
param asgResourceId string

@sys.description('Deploy Fslogix setup.')
param configureFslogix bool

@sys.description('Path for the FSlogix share.')
param fslogixSharePath string

@sys.description('FSLogix storage account resource ID.')
param fslogixStorageAccountResourceId string

@sys.description('Host pool resource ID.')
param hostPoolResourceId string

// @sys.description('FSLogix storage account FDQN.')
// param fslogixStorageFqdn string

@sys.description('URI for AVD session host configuration script URI.')
param sessionHostConfigurationScriptUri string

@sys.description('URI for AVD session host configuration script.')
param sessionHostConfigurationScript string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Log analytics workspace for diagnostic logs.')
param alaWorkspaceResourceId string

@sys.description('Deploy AVD monitoring resources and setings.')
param deployMonitoring bool

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Data collection rule ID.')
param dataCollectionRuleId string

@sys.description('Deploys anti malware extension on session hosts.')
param deployAntiMalwareExt bool

@sys.description('The ARPA-H Developer Entra ID security group')
param securityPrincipalId string

@description('Optional. Required if name is specified. Password of the user specified in user parameter.')
@secure()
param domainJoinPassword string = ''

// =========== //
// Variable declaration //
// =========== //
var varManagedDisk = empty(diskEncryptionSetResourceId) ? {
    storageAccountType: diskType
} : {
    diskEncryptionSetResourceId: diskEncryptionSetResourceId
    storageAccountType: diskType
}
var varOsDiskProperties = {
    createOption: 'FromImage'
    deleteOption: 'Delete'
    caching: 'ReadWrite'
    managedDisk: varManagedDisk
    //diskSizeGB: 128
}
var varCustomOsDiskProperties = {
    createOption: 'FromImage'
    deleteOption: 'Delete'
    caching: 'ReadWrite'
    managedDisk: varManagedDisk
    diskSizeGB: !empty(customOsDiskSizeGB ) ? customOsDiskSizeGB : null
}

// var devSecurityGroupPrincipalId = '19cfe65e-52b6-49e5-8155-02843498171d'

var varCustomDeveloperRole = {
    id: '71d5079f-3e16-4911-b7c2-4bdb44d3eb63'
    name: 'ARPA-H-AVD-Developer-Role'
  }
  
// =========== //
// Deployments //
// =========== //

// call on the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
    name: wrklKvName
    scope: resourceGroup('${subscriptionId}', '${serviceObjectsRgName}')
}

// Session hosts
module sessionHosts '../../../../avm/1.0.0/res/compute/virtual-machine/main-arpah.bicep' = [for i in range(1, count): {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-${batchId}-${i - 1}-${time}'
    params: {
        name: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        location: location
        timeZone: timeZone
        zone: useAvailabilityZones ? (i % 3 + 1) : 0
        managedIdentities: (identityServiceProvider == 'EntraID' || deployMonitoring) ? {
            systemAssigned: true
        }: null
        encryptionAtHost: encryptionAtHost
        //virtualMachineScaleSetResourceId: useVmssFlex ? '/subscriptions/${subscriptionId}/resourceGroups/${computeObjectsRgName}/providers/Microsoft.Compute/virtualMachineScaleSets/${vmssFlexNamePrefix}-${padLeft(((1 + (i + countIndex) / maxVmssFlexMembersCount)), 3, '0')}': ''
        osType: 'Windows'
        licenseType: 'Windows_Client'
        vmSize: vmSize
        securityType: (securityType == 'Standard') ? '' : securityType
        secureBootEnabled: secureBootEnabled
        vTpmEnabled: vTpmEnabled
        imageReference: useSharedImage ? json('{\'id\': \'${avdImageTemplateDefinitionId}\'}') : marketPlaceGalleryWindows
        osDisk: !empty(customOsDiskSizeGB ) ? varCustomOsDiskProperties : varOsDiskProperties
        //adminUsername: vmLocalUserName
        adminUsername: keyVault.getSecret('vmLocalUserName')
        adminPassword: keyVault.getSecret('vmLocalUserPassword')
        nicConfigurations: [
            {
                name: 'nic-01-${namePrefix}${padLeft((i + countIndex), 4, '0')}'
                deleteOption: 'Delete'
                enableAcceleratedNetworking: enableAcceleratedNetworking
                ipConfigurations: !empty(asgResourceId) ? [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: subnetId
                        applicationSecurityGroups: [
                            {
                                id: asgResourceId
                            }
                        ]
                    }
                ] : [
                    {
                        name: 'ipconfig01'
                        subnetResourceId: subnetId
                    }
                ]
            }
        ]
        // ADDS or EntraDS domain join.
        extensionDomainJoinPassword: keyVault.getSecret('domainJoinUserPassword')
        extensionDomainJoinConfig: {
            //enabled: (identityServiceProvider == 'EntraDS' || identityServiceProvider == 'ADDS') ? true : false
            enabled: false
            settings: {
                name: identityDomainName
                ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
                user: domainJoinUserName
                restart: 'true'
                options: '3'

            }
        }
        // Microsoft Entra ID Join.
        extensionAadJoinConfig: {
            enabled: (identityServiceProvider == 'EntraID') ? true : false
            settings: createIntuneEnrollment ? {
               mdmId: '0000000a-0000-0000-c000-000000000000'
            } : {}
        }
        // antimalware
        extensionAntiMalwareConfig: {
            enabled: false // JWI: testing, set this to false, and deploy it from this file
            settings: {
                AntimalwareEnabled: true
                RealtimeProtectionEnabled: 'true'
                ScheduledScanSettings: {
                    isEnabled: 'true'
                    day: '7' // Day of the week for scheduled scan (1-Sunday, 2-Monday, ..., 7-Saturday)
                    time: '120' // When to perform the scheduled scan, measured in minutes from midnight (0-1440). For example: 0 = 12AM, 60 = 1AM, 120 = 2AM.
                    scanType: 'Quick' //Indicates whether scheduled scan setting type is set to Quick or Full (default is Quick)
                }
                Exclusions: configureFslogix ? {
                    Extensions: '*.vhd;*.vhdx'
                    Paths: '"%ProgramFiles%\\FSLogix\\Apps\\frxdrv.sys;%ProgramFiles%\\FSLogix\\Apps\\frxccd.sys;%ProgramFiles%\\FSLogix\\Apps\\frxdrvvt.sys;%TEMP%\\*.VHD;%TEMP%\\*.VHDX;%Windir%\\TEMP\\*.VHD;%Windir%\\TEMP\\*.VHDX;${fslogixSharePath}\\*\\*.VHD;${fslogixSharePath}\\*\\*.VHDX'
                    Processes: '%ProgramFiles%\\FSLogix\\Apps\\frxccd.exe;%ProgramFiles%\\FSLogix\\Apps\\frxccds.exe;%ProgramFiles%\\FSLogix\\Apps\\frxsvc.exe'
                } : {}
            }
        }
        tags: tags
        principalId: securityPrincipalId
        roleDefinitionResourceId:'/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varCustomDeveloperRole.id}'
    }
    dependsOn: [
        keyVault
    ]
}]

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for i in range(1, count): {
//     scope: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
//     name: guid(storageAccount.id, devSecurityGroupPrincipalId, roleDefinitionResourceId)
//     properties: {
//       //roleDefinitionId: roleDefinitionResourceId
//       roleDefinitionId: '/subscriptions/${subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${varVirtualMachineUserLoginRole.id}'
//       principalId: '19cfe65e-52b6-49e5-8155-02843498171d'
//       principalType: 'Group'
//     }
// }]

// Add antimalware extension to session host.
module sessionHostsAntimalwareExtension '../../../../avm/1.0.0/res/compute/virtual-machine/extension/main.bicep' = [for i in range(1, count): if (deployAntiMalwareExt) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Antimal-${batchId}-${i - 1}-${time}'
    params: {
        location: location
        virtualMachineName: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        name: 'MicrosoftAntiMalware'
        publisher: 'Microsoft.Azure.Security'
        type: 'IaaSAntimalware'
        typeHandlerVersion: '1.7'
        autoUpgradeMinorVersion: true
        enableAutomaticUpgrade: false
        settings: {
            AntimalwareEnabled: true
            RealtimeProtectionEnabled: 'true'
            ScheduledScanSettings: {
                isEnabled: 'true'
                day: '7' // Day of the week for scheduled scan (1-Sunday, 2-Monday, ..., 7-Saturday)
                time: '120' // When to perform the scheduled scan, measured in minutes from midnight (0-1440). For example: 0 = 12AM, 60 = 1AM, 120 = 2AM.
                scanType: 'Quick' //Indicates whether scheduled scan setting type is set to Quick or Full (default is Quick)
            }
            Exclusions: configureFslogix ? {
                Extensions: '*.vhd;*.vhdx'
                Paths: '"%ProgramFiles%\\FSLogix\\Apps\\frxdrv.sys;%ProgramFiles%\\FSLogix\\Apps\\frxccd.sys;%ProgramFiles%\\FSLogix\\Apps\\frxdrvvt.sys;%TEMP%\\*.VHD;%TEMP%\\*.VHDX;%Windir%\\TEMP\\*.VHD;%Windir%\\TEMP\\*.VHDX;${fslogixSharePath}\\*\\*.VHD;${fslogixSharePath}\\*\\*.VHDX'
                Processes: '%ProgramFiles%\\FSLogix\\Apps\\frxccd.exe;%ProgramFiles%\\FSLogix\\Apps\\frxccds.exe;%ProgramFiles%\\FSLogix\\Apps\\frxsvc.exe'
            } : {}
        }
    }
    dependsOn: [
        sessionHosts
    ]
}]

// Call to the ALA workspace
resource alaWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (!empty(alaWorkspaceResourceId) && deployMonitoring) {
    scope: az.resourceGroup(split(alaWorkspaceResourceId, '/')[2], split(alaWorkspaceResourceId, '/')[4])
    name: last(split(alaWorkspaceResourceId, '/'))!
}

// Add monitoring extension to session host
module monitoring '../../../../avm/1.0.0/res/compute/virtual-machine/extension/main.bicep' = [for i in range(1, count): if (deployMonitoring) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Mon-${batchId}-${i - 1}-${time}'
    params: {
        location: location
        virtualMachineName: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        name: 'AzureMonitorWindowsAgent'
        publisher: 'Microsoft.Azure.Monitor'
        type: 'AzureMonitorWindowsAgent'
        typeHandlerVersion: '1.0'
        autoUpgradeMinorVersion: true
        enableAutomaticUpgrade: true
        settings: {
            workspaceId: !empty(alaWorkspaceResourceId) ? reference(alaWorkspace.id, alaWorkspace.apiVersion).customerId : ''
        }
        protectedSettings: {
            workspaceKey: !empty(alaWorkspaceResourceId) ? alaWorkspace.listKeys().primarySharedKey : ''
        }
    }
    dependsOn: [
        sessionHostsAntimalwareExtension
        alaWorkspace
    ]
}]

// Data collection rule association
module dataCollectionRuleAssociation '.bicep/dataCollectionRulesAssociation.bicep' = [for i in range(1, count): if (deployMonitoring) {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'DCR-Asso-${batchId}-${i - 1}-${time}'
    params: {
        virtualMachineName: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        dataCollectionRuleId: dataCollectionRuleId
    }
    dependsOn: [
        // monitoring
        // //sessionHostsAntimalwareExtension
        // sessionHosts
        // alaWorkspace
        monitoring
        sessionHostsAntimalwareExtension
        alaWorkspace
    ]
}]

// Apply AVD session host configurations
module sessionHostConfiguration '.bicep/configureSessionHost.bicep' = [for i in range(1, count): {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    name: 'SH-Config-${batchId}-${i}-${time}'
    params: {
        location: location
        name: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
        hostPoolResourceId: hostPoolResourceId
        baseScriptUri: sessionHostConfigurationScriptUri
        scriptName: sessionHostConfigurationScript
        fslogix: configureFslogix
        identityDomainName: identityDomainName
        vmSize: vmSize
        fslogixSharePath: fslogixSharePath
        extendOsDisk: customOsDiskSizeGB != 0 ? true : false
        fslogixStorageAccountResourceId: fslogixStorageAccountResourceId
        identityServiceProvider: identityServiceProvider
    }
    dependsOn: [
        sessionHosts
        monitoring
    ]
}]

// module sessionHostConfiguration '.bicep/configureSessionHost.bicep' = [
//     for i in range(0, count): {
//       scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
//       name: 'SH-Config-${batchId + 1}-${i + countIndex}-${time}'
//       params: {
//         baseScriptUri: sessionHostConfigurationScriptUri
//         fslogix: configureFslogix
//         fslogixSharePath: fslogixSharePath
//         fslogixStorageAccountResourceId: fslogixStorageAccountResourceId
//         hostPoolResourceId: hostPoolResourceId
//         identityDomainName: identityDomainName
//         identityServiceProvider: identityServiceProvider
//         location: location
//         name: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
//         scriptName: sessionHostConfigurationScript
//         vmSize: vmSize
//       }
//       dependsOn: [
//         sessionHosts
//         ama
//       ]
//     }
//   ]

// extensionDomainJoinPassword: keyVault.getSecret('domainJoinUserPassword')
//         extensionDomainJoinConfig: {
//             enabled: (identityServiceProvider == 'EntraDS' || identityServiceProvider == 'ADDS') ? true : false
//             settings: {
//                 name: identityDomainName
//                 ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
//                 user: domainJoinUserName
//                 restart: 'true'
//                 options: '3'

//             }
//         }

module vm_domainJoinExtension '../../../../avm/1.0.0/res/compute/virtual-machine/extension/main.bicep' = [for i in range(1, count): {
    scope: resourceGroup('${subscriptionId}', '${computeObjectsRgName}')
    //name: '${uniqueString(deployment().name, location)}-VM-DomainJoin'
    name: 'Dom-Join-${batchId}-${i}-${time}'
    params: {
      virtualMachineName: '${namePrefix}${padLeft((i + countIndex), 4, '0')}'
      name: 'DomainJoin'
      location: location
      publisher: 'Microsoft.Compute'
      type: 'JsonADDomainExtension'
      typeHandlerVersion: '1.3'
      autoUpgradeMinorVersion: true
      enableAutomaticUpgrade: false
      settings: {
            name: identityDomainName
            ouPath: !empty(sessionHostOuPath) ? sessionHostOuPath : null
            user: domainJoinUserName
            restart: 'true'
            options: '3'
        }
      
      supressFailures: false
      tags: tags
      protectedSettings: {
        Password: domainJoinPassword
        //Password: secure(keyVault.getSecret('domainJoinUserPassword'))
        }
    }
    dependsOn: [
        sessionHostConfiguration
    ]
  }]
