metadata name = 'AVD Accelerator - Developer Host Pool Deployment'
metadata description = 'AVD Accelerator - Deployment Developer Host Pool'

targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@minLength(2)
@maxLength(4)
@sys.description('The name of the resource group to deploy. (Default: AVD1)')
param deploymentPrefix string = 'AVDN'

@allowed([
    'Dev' // Development
    'Test' // Test
    'Prod' // Production
])
@sys.description('The name of the resource group to deploy. (Default: Dev)')
param deploymentEnvironment string = 'Test'

@allowed([
    'Developer'
    'Admin'
])
@sys.description('The name of type of host pool to use for deploying session hosts to. (Default: developer)')
param hostPoolPersona string = 'Developer'

@sys.description('Location where to deploy compute services. (Default: eastus2)')
param avdSessionHostLocation string = 'eastus2'

@sys.description('Location where to deploy AVD management plane. (Default: eastus2)')
param avdManagementPlaneLocation string = 'eastus2'

@sys.description('AVD workload subscription ID, multiple subscriptions scenario. (Default: "")')
param avdWorkloadSubsId string = ''

@sys.description('Azure Virtual Desktop Enterprise Application object ID. (Default: "")')
param avdEnterpriseAppObjectId string = ''

@allowed([
    'ADDS' // Active Directory Domain Services
    'EntraDS' // Microsoft Entra Domain Services
    'EntraID' // Microsoft Entra ID Join
])
@sys.description('Required, The service providing domain services for Azure Virtual Desktop. (Default: ADDS)')
param avdIdentityServiceProvider string = 'ADDS'

// This is the object id for the 'ARPA-H AVD Default' MS Entra Group
@sys.description('Optional, Identity ID to grant RBAC role to access AVD application group and NTFS permissions. (Default: "")')
param securityPrincipalId string = ''

@allowed([
    'Personal'
    'Pooled'
])
@sys.description('AVD host pool type. (Default: Pooled)')
param avdHostPoolType string = 'Pooled'

@sys.description('Optional. The type of preferred application group type, default to Desktop Application Group.')
@allowed([
    'Desktop'
    'RemoteApp'
])
param hostPoolPreferredAppGroupType string = 'Desktop'

@allowed([
    'Disabled' // Blocks public access and requires both clients and session hosts to use the private endpoints
    'Enabled' // Allow clients and session hosts to communicate over the public network
    'EnabledForClientsOnly' // Allows only clients to access AVD over public network
    'EnabledForSessionHostsOnly' // Allows only the session hosts to communicate over the public network
  ])
@sys.description('Enables or Disables public network access on the host pool. (Default: Enabled.)')
param hostPoolPublicNetworkAccess string = 'Enabled'

// @allowed([
// 'Disabled'
// 'Enabled'
// ])
// @sys.description('Default to Enabled. Enables or Disables public network access on the workspace.')
// param workspacePublicNetworkAccess string = 'Enabled'

@allowed([
    'Automatic'
    'Direct'
])
@sys.description('AVD host pool type. (Default: Automatic)')
param avdPersonalAssignType string = 'Automatic'

@allowed([
    'BreadthFirst'
    'DepthFirst'
])
@sys.description('AVD host pool load balacing type. (Default: BreadthFirst)')
param avdHostPoolLoadBalancerType string = 'BreadthFirst'

@sys.description('AVD host pool maximum number of user sessions per session host. (Default: 8)')
param hostPoolMaxSessions int = 8

@sys.description('AVD host pool start VM on Connect. (Default: true)')
param avdStartVmOnConnect bool = true

@sys.description('AVD host pool Custom RDP properties. (Default: audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2)')
param avdHostPoolRdpProperties string = 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2;enablerdsaadauth:i:1'

@sys.description('AVD deploy scaling plan. (Default: true)')
param avdDeployScalingPlan bool = true

@sys.description('Existing virtual network subnet for private endpoints. (Default: "")')
param existingVnetPrivateEndpointSubnetResourceId string = ''

@sys.description('Deploys the private link for AVD. Requires resource provider registration or re-registration. (Default: false)')
param deployAvdPrivateLinkService bool = false

@allowed([
    'win10_21h2'
    'win10_21h2_office'
    'win10_22h2_g2'
    'win10_22h2_office_g2'
    'win11_21h2'
    'win11_21h2_office'
    'win11_22h2'
    'win11_22h2_office'
    'win11_23h2'
    'win11_23h2_office'
])
@sys.description('AVD OS image SKU. (Default: win11-22h2)')
param avdOsImage string = 'win11_23h2_office'

// Custom Naming
// Input must followe resource naming rules on https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules
@sys.description('AVD resources custom naming. (Default: false)')
param avdUseCustomNaming bool = true

@maxLength(90)
@sys.description('AVD service resources resource group custom name. (Default: rg-avd-app1-dev-use2-service-objects)')
param avdServiceObjectsRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-service-objects'

@maxLength(90)
@sys.description('AVD monitoring resource group custom name. (Default: rg-avd-dev-use2-monitoring)')
param avdMonitoringRgCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-monitoring'

@maxLength(64)
@sys.description('AVD Azure log analytics workspace custom name. (Default: log-avd-app1-dev-use2)')
param avdAlaWorkspaceCustomName string = 'avd-nih-arpah-${toLower(deploymentEnvironment)}-use2-log'

@maxLength(64)
@sys.description('AVD workspace custom name. (Default: vdws-app1-dev-use2-001)')
//param avdWorkSpaceCustomName string = 'vdws-${toLower(hostPoolPersona)}-${toLower(deploymentEnvironment)}-use2-001'
param avdWorkSpaceCustomName string = 'vdws-app1-${toLower(deploymentEnvironment)}-use2-001'

// @maxLength(64)
// @sys.description('AVD workspace custom friendly (Display) name. (Default: App1 - Dev - East US 2 - 001)')
// param avdWorkSpaceCustomFriendlyName string = 'ARPA-H on NIH Network - ${deploymentEnvironment}'

@maxLength(64)
@sys.description('AVD host pool custom name. (Default: vdpool-app1-dev-use2-001)')
param avdHostPoolCustomName string = 'vdpool-${toLower(hostPoolPersona)}-${toLower(avdHostPoolType)}-${toLower(deploymentEnvironment)}-use2-001'

@maxLength(64)
@sys.description('AVD host pool custom friendly (Display) name. (Default: App1 - East US - Dev - 001)')
param avdHostPoolCustomFriendlyName string = 'ARPA-H on NIH Network - ${deploymentEnvironment}'

@maxLength(64)
@sys.description('AVD scaling plan custom name. (Default: vdscaling-app1-dev-use2-001)')
param avdScalingPlanCustomName string = 'vdscaling-${toLower(hostPoolPersona)}-${toLower(avdHostPoolType)}-${toLower(deploymentEnvironment)}-use2-001'

@maxLength(64)
@sys.description('AVD desktop application group custom name. (Default: vdag-desktop-app1-dev-use2-001)')
param avdApplicationGroupCustomName string = 'vdag-desktop-${toLower(hostPoolPersona)}--${toLower(avdHostPoolType)}-${toLower(deploymentEnvironment)}-use2-001'

@maxLength(64)
@sys.description('AVD desktop application group custom friendly (Display) name. (Default: Desktops - App1 - East US - Dev - 001)')
param avdApplicationGroupCustomFriendlyName string = 'ARPA-H on NIH Network - ${deploymentPrefix}'

@maxLength(6)
@sys.description('AVD keyvault prefix custom name (with Zero Trust to store credentials to domain join and local admin). (Default: kv-sec)')
param avdWrklKvPrefixCustomName string = 'kv-sec'

//
// Resource tagging
//
@sys.description('Apply tags on resources and resource groups. (Default: false)')
param createResourceTags bool = false

@sys.description('The name of workload for tagging purposes. (Default: Contoso-Workload)')
param workloadNameTag string = 'AVD ${deploymentEnvironment} ARPA-H ${hostPoolPersona} on NIH Network '

@allowed([
    'Light'
    'Medium'
    'High'
    'Power'
])
@sys.description('Reference to the size of the VM for your workloads (Default: Light)')
param workloadTypeTag string = 'Light'

@allowed([
    'Non-business'
    'Public'
    'General'
    'Confidential'
    'Highly-confidential'
])
@sys.description('Sensitivity of data hosted (Default: Non-business)')
param dataClassificationTag string = 'Non-business'

@sys.description('Department that owns the deployment, (Dafult: Contoso-AVD)')
param departmentTag string = 'ARPA-H-AVD'

@allowed([
    'Low'
    'Medium'
    'High'
    'Mission-critical'
    'Custom'
])
@sys.description('Criticality of the workload. (Default: Low)')
param workloadCriticalityTag string = 'Low'

@sys.description('Tag value for custom criticality value. (Default: Contoso-Critical)')
param workloadCriticalityCustomValueTag string = 'ARPA-H-Critical'

@sys.description('Details about the application.')
param applicationNameTag string = 'ARPA-H-AVD'

@sys.description('Service level agreement level of the worload. (Contoso-SLA)')
param workloadSlaTag string = 'ARPA-H-SLA'

@sys.description('Team accountable for day-to-day operations. (workload-admins@Contoso.com)')
param opsTeamTag string = 'workload-admins@arpa-h.gov'

@sys.description('Organizational owner of the AVD deployment. (Default: workload-owner@Contoso.com)')
param ownerTag string = 'workload-owner@arpa-h.gov'

@sys.description('Cost center of owner team. (Default: Contoso-CC)')
param costCenterTag string = 'ARPA-H-CC'

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

@sys.description('Enable usage and telemetry feedback to Microsoft.')
param enableTelemetry bool = true

// =========== //
// Variable declaration //
// =========== //
// Resource naming
var varDeploymentPrefixLowercase = toLower(deploymentPrefix)
var varAzureCloudName = environment().name
var varDeploymentEnvironmentLowercase = toLower(deploymentEnvironment)
var varNamingUniqueStringTwoChar = take('${uniqueString(avdWorkloadSubsId, varDeploymentPrefixLowercase, time)}', 2)
var varSessionHostLocationAcronym = varLocations[varSessionHostLocationLowercase].acronym
var varManagementPlaneLocationAcronym = varLocations[varManagementPlaneLocationLowercase].acronym
var varLocations = loadJsonContent('../variables/locations-arpah.json')
var varTimeZoneSessionHosts = varLocations[varSessionHostLocationLowercase].timeZone
var varManagementPlaneNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}'
var varComputeStorageResourcesNamingStandard = '${varDeploymentPrefixLowercase}-${varDeploymentEnvironmentLowercase}-${varSessionHostLocationAcronym}'
var varSessionHostLocationLowercase = toLower(replace(avdSessionHostLocation, ' ', ''))
var varManagementPlaneLocationLowercase = toLower(replace(avdManagementPlaneLocation, ' ', ''))
var varServiceObjectsRgName = avdUseCustomNaming 
    ? avdServiceObjectsRgCustomName 
    : 'rg-avd-${varManagementPlaneNamingStandard}-service-objects' // max length limit 90 characters
var varMonitoringRgName = avdUseCustomNaming 
    ? avdMonitoringRgCustomName 
    : 'rg-avd-${varDeploymentEnvironmentLowercase}-${varManagementPlaneLocationAcronym}-monitoring' // max length limit 90 characters
var varWorkSpaceName = avdUseCustomNaming ? avdWorkSpaceCustomName : 'vdws-${varManagementPlaneNamingStandard}-001'
// var varWorkSpaceFriendlyName = avdUseCustomNaming 
//     ? avdWorkSpaceCustomFriendlyName 
//     : 'Workspace ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varHostPoolName = avdUseCustomNaming ? avdHostPoolCustomName : 'vdpool-${varManagementPlaneNamingStandard}-001'
var varHostFriendlyName = avdUseCustomNaming 
    ? avdHostPoolCustomFriendlyName 
    : 'Hostpool ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varHostPoolPreferredAppGroupType = toLower(hostPoolPreferredAppGroupType)
var varApplicationGroupName = avdUseCustomNaming 
    ? avdApplicationGroupCustomName 
    : 'vdag-${varHostPoolPreferredAppGroupType}-${varManagementPlaneNamingStandard}-001'
var varApplicationGroupFriendlyName = avdUseCustomNaming 
    ? avdApplicationGroupCustomFriendlyName 
    : '${varHostPoolPreferredAppGroupType} ${deploymentPrefix} ${deploymentEnvironment} ${avdManagementPlaneLocation} 001'
var varDeployScalingPlan = (varAzureCloudName == 'AzureChinaCloud') ? false : avdDeployScalingPlan
var varScalingPlanName = avdUseCustomNaming 
    ? avdScalingPlanCustomName 
    : 'vdscaling-${varManagementPlaneNamingStandard}-001'
var varPrivateEndPointConnectionName = 'pe-${varHostPoolName}-connection'
// var varPrivateEndPointDiscoveryName = 'pe-${varWorkSpaceName}-discovery'
// var varPrivateEndPointWorkspaceName = 'pe-${varWorkSpaceName}-global'
var varScalingPlanExclusionTag = 'exclude-${varScalingPlanName}'
var varScalingPlanWeekdaysScheduleName = 'Weekdays-${varManagementPlaneNamingStandard}'
var varScalingPlanWeekendScheduleName = 'Weekend-${varManagementPlaneNamingStandard}'
var varWrklKvName = avdUseCustomNaming 
    ? '${avdWrklKvPrefixCustomName}-${varComputeStorageResourcesNamingStandard}' 
    : 'kv-sec-${varComputeStorageResourcesNamingStandard}-${varNamingUniqueStringTwoChar}' // max length limit 24 characters

var varHostPoolAgentUpdateSchedule = [
    {
        dayOfWeek: 'Tuesday'
        hour: 18
    }
    {
        dayOfWeek: 'Friday'
        hour: 17
    }
]
var varPersonalScalingPlanSchedules = [
  {
    daysOfWeek: [
      'Monday'
      'Wednesday'
      'Thursday'
      'Friday'
    ]
    name: varScalingPlanWeekdaysScheduleName
    offPeakStartTime: {
      hour: 20
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Deallocate'
    peakStartTime: {
      hour: 9
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Deallocate'
    rampDownStartTime: {
      hour: 18
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Deallocate'
    rampUpStartTime: {
      hour: 7
      minute: 0
    }
    rampUpAutoStartHosts: 'WithAssignedUser'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Deallocate'
  }
  {
    daysOfWeek: [
      'Tuesday'
    ]
    name: '${varScalingPlanWeekdaysScheduleName}-agent-updates'
    offPeakStartTime: {
      hour: 20
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Deallocate'
    peakStartTime: {
      hour: 9
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Deallocate'
    rampDownStartTime: {
      hour: 18
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Deallocate'
    rampUpStartTime: {
      hour: 7
      minute: 0
    }
    rampUpAutoStartHosts: 'WithAssignedUser'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Deallocate'
  }
  {
    daysOfWeek: [
      'Saturday'
      'Sunday'
    ]
    name: varScalingPlanWeekendScheduleName
    offPeakStartTime: {
      hour: 18
      minute: 0
    }
    offPeakStartVMOnConnect: 'Enable'
    offPeakMinutesToWaitOnDisconnect: 30
    offPeakActionOnDisconnect: 'Hibernate'
    offPeakMinutesToWaitOnLogoff: 0
    offPeakActionOnLogoff: 'Deallocate'
    peakStartTime: {
      hour: 10
      minute: 0
    }
    peakStartVMOnConnect: 'Enable'
    peakMinutesToWaitOnDisconnect: 30
    peakActionOnDisconnect: 'Hibernate'
    peakMinutesToWaitOnLogoff: 0
    peakActionOnLogoff: 'Deallocate'
    rampDownStartTime: {
      hour: 16
      minute: 0
    }
    rampDownStartVMOnConnect: 'Enable'
    rampDownMinutesToWaitOnDisconnect: 30
    rampDownActionOnDisconnect: 'Hibernate'
    rampDownMinutesToWaitOnLogoff: 0
    rampDownActionOnLogoff: 'Deallocate'
    rampUpStartTime: {
      hour: 9
      minute: 0
    }
    rampUpAutoStartHosts: 'None'
    rampUpStartVMOnConnect: 'Enable'
    rampUpMinutesToWaitOnDisconnect: 30
    rampUpActionOnDisconnect: 'Hibernate'
    rampUpMinutesToWaitOnLogoff: 0
    rampUpActionOnLogoff: 'Deallocate'
  }
]
var varPooledScalingPlanSchedules = [
    {
        daysOfWeek: [
            'Monday'
            'Wednesday'
            'Thursday'
            'Friday'
        ]
        name: varScalingPlanWeekdaysScheduleName
        offPeakLoadBalancingAlgorithm: 'DepthFirst'
        offPeakStartTime: {
            hour: 20
            minute: 0
        }
        peakLoadBalancingAlgorithm: 'DepthFirst'
        peakStartTime: {
            hour: 9
            minute: 0
        }
        rampDownCapacityThresholdPct: 90
        rampDownForceLogoffUsers: true
        rampDownLoadBalancingAlgorithm: 'DepthFirst'
        rampDownMinimumHostsPct: 0 //10
        rampDownNotificationMessage: 'You will be logged off in 30 min. Make sure to save your work.'
        rampDownStartTime: {
            hour: 18
            minute: 0
        }
        rampDownStopHostsWhen: 'ZeroActiveSessions'
        rampDownWaitTimeMinutes: 30
        rampUpCapacityThresholdPct: 80
        rampUpLoadBalancingAlgorithm: 'BreadthFirst'
        rampUpMinimumHostsPct: 20
        rampUpStartTime: {
            hour: 7
            minute: 0
        }
    }
    {
        daysOfWeek: [
            'Tuesday'
        ]
        name: '${varScalingPlanWeekdaysScheduleName}-agent-updates'
        offPeakLoadBalancingAlgorithm: 'DepthFirst'
        offPeakStartTime: {
            hour: 20
            minute: 0
        }
        peakLoadBalancingAlgorithm: 'DepthFirst'
        peakStartTime: {
            hour: 9
            minute: 0
        }
        rampDownCapacityThresholdPct: 90
        rampDownForceLogoffUsers: true
        rampDownLoadBalancingAlgorithm: 'DepthFirst'
        rampDownMinimumHostsPct: 0 //10
        rampDownNotificationMessage: 'You will be logged off in 30 min. Make sure to save your work.'
        rampDownStartTime: {
            hour: 19
            minute: 0
        }
        rampDownStopHostsWhen: 'ZeroActiveSessions'
        rampDownWaitTimeMinutes: 30
        rampUpCapacityThresholdPct: 80
        rampUpLoadBalancingAlgorithm: 'BreadthFirst'
        rampUpMinimumHostsPct: 20
        rampUpStartTime: {
            hour: 7
            minute: 0
        }
    }
    {
        daysOfWeek: [
            'Saturday'
            'Sunday'
        ]
        name: varScalingPlanWeekendScheduleName
        offPeakLoadBalancingAlgorithm: 'DepthFirst'
        offPeakStartTime: {
            hour: 18
            minute: 0
        }
        peakLoadBalancingAlgorithm: 'DepthFirst'
        peakStartTime: {
            hour: 4
            minute: 0
        }
        rampDownCapacityThresholdPct: 90
        rampDownForceLogoffUsers: true
        rampDownLoadBalancingAlgorithm: 'DepthFirst'
        rampDownMinimumHostsPct: 0
        rampDownNotificationMessage: 'You will be logged off in 30 min. Make sure to save your work.'
        rampDownStartTime: {
            hour: 16
            minute: 0
        }
        rampDownStopHostsWhen: 'ZeroActiveSessions'
        rampDownWaitTimeMinutes: 30
        rampUpCapacityThresholdPct: 80
        rampUpLoadBalancingAlgorithm: 'DepthFirst'
        rampUpMinimumHostsPct: 20
        rampUpStartTime: {
            hour: 3
            minute: 0
        }
    }
]
// var varMarketPlaceGalleryWindows = loadJsonContent('../variables/osMarketPlaceImages.json')
// Resource tagging
// Tag Exclude-${varAvdScalingPlanName} is used by scaling plans to exclude session hosts from scaling. Exmaple: Exclude-vdscal-eus2-app1-dev-001
var varCustomResourceTags = createResourceTags ? {
    WorkloadName: workloadNameTag
    WorkloadType: workloadTypeTag
    DataClassification: dataClassificationTag
    Department: departmentTag
    Criticality: (workloadCriticalityTag == 'Custom') ? workloadCriticalityCustomValueTag : workloadCriticalityTag
    ApplicationName: applicationNameTag
    ServiceClass: workloadSlaTag
    OpsTeam: opsTeamTag
    Owner: ownerTag
    CostCenter: costCenterTag
} : {}

var varAvdDefaultTags = {
    'cm-resource-parent': '/subscriptions/${avdWorkloadSubsId}/resourceGroups/${varServiceObjectsRgName}/providers/Microsoft.DesktopVirtualization/hostpools/${varHostPoolName}'
    Environment: deploymentEnvironment
    ServiceWorkload: 'AVD'
    CreationTimeUTC: time
}

// var varZtKeyvaultTag = {
//     Purpose: 'Disk encryption keys for zero trust'
// }
var varTelemetryId = 'pid-2ce4228c-d72c-43fb-bb5b-cd8f3ba2138e-${avdManagementPlaneLocation}'

// =========== //
// Deployments //
// =========== //

//  Telemetry Deployment
resource telemetrydeployment 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
    name: varTelemetryId
    location: avdManagementPlaneLocation
    properties: {
        mode: 'Incremental'
        template: {
            '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
            contentVersion: '1.0.0.0'
            resources: []
        }
    }
}

module managementPLane './modules/avdManagementPlane/deploy-developer-arpah.bicep' = {
    name: 'AVD-MGMT-Plane-${time}'
    params: {
      applicationGroupName: varApplicationGroupName
      applicationGroupFriendlyNameDesktop: varApplicationGroupFriendlyName
      workSpaceName: varWorkSpaceName
      osImage: avdOsImage
      keyVaultResourceId: keyVaultExisting.id
      //workSpaceFriendlyName: varWorkSpaceFriendlyName
      computeTimeZone: varTimeZoneSessionHosts
      hostPoolName: varHostPoolName
      hostPoolFriendlyName: varHostFriendlyName
      hostPoolRdpProperties: avdHostPoolRdpProperties
      hostPoolLoadBalancerType: avdHostPoolLoadBalancerType
      hostPoolType: avdHostPoolType
      preferredAppGroupType: (hostPoolPreferredAppGroupType == 'RemoteApp') ? 'RailApplications' : 'Desktop'
      deployScalingPlan: !empty(avdEnterpriseAppObjectId) ? varDeployScalingPlan : false
      scalingPlanExclusionTag: varScalingPlanExclusionTag
      scalingPlanSchedules: (avdHostPoolType == 'Pooled')
        ? varPooledScalingPlanSchedules
        : varPersonalScalingPlanSchedules
      scalingPlanName: varScalingPlanName
      hostPoolMaxSessions: hostPoolMaxSessions
      personalAssignType: avdPersonalAssignType
      managementPlaneLocation: avdManagementPlaneLocation
      serviceObjectsRgName: varServiceObjectsRgName
      startVmOnConnect: avdStartVmOnConnect
      subscriptionId: avdWorkloadSubsId
      identityServiceProvider: avdIdentityServiceProvider
      securityPrincipalId: securityPrincipalId
      tags: createResourceTags ? union(varCustomResourceTags, varAvdDefaultTags) : varAvdDefaultTags
      alaWorkspaceResourceId: logAnalyticsWorkspaceExisting.id
      hostPoolAgentUpdateSchedule: varHostPoolAgentUpdateSchedule
      deployAvdPrivateLinkService: deployAvdPrivateLinkService
      hostPoolPublicNetworkAccess: hostPoolPublicNetworkAccess
      //workspacePublicNetworkAccess: workspacePublicNetworkAccess
      privateEndpointSubnetResourceId: existingVnetPrivateEndpointSubnetResourceId
      //avdVnetPrivateDnsZoneDiscoveryResourceId: ''
      avdVnetPrivateDnsZoneConnectionResourceId: ''
      privateEndpointConnectionName: varPrivateEndPointConnectionName
      // privateEndpointDiscoveryName: varPrivateEndPointDiscoveryName
      // privateEndpointWorkspaceName: varPrivateEndPointWorkspaceName
    }
}

// retrieve existing resources
resource keyVaultExisting 'Microsoft.KeyVault/vaults@2024-12-01-preview' existing = {
  name: varWrklKvName
  scope: resourceGroup('${avdWorkloadSubsId}', '${varServiceObjectsRgName}')
}

resource logAnalyticsWorkspaceExisting 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: avdAlaWorkspaceCustomName
  scope: resourceGroup('${avdWorkloadSubsId}', '${varMonitoringRgName}')
}
