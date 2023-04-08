targetScope = 'subscription'

@description('Optional. Tags for the resource group. If not provided, removes existing tags.')
param tags object = {}

@description('Optional. Instead of overwriting the existing tags, combine them with the new tags.')
param onlyUpdate bool = false

@sys.description('Optional. Location deployment metadata.')
param location string = deployment().location

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

module readTags '.bicep/readTags.bicep' = if (onlyUpdate) {
  name: '${deployment().name}-ReadTags'
}

var newTags = (onlyUpdate) ? union(readTags.outputs.existingTags, tags) : tags

resource tag 'Microsoft.Resources/tags@2021-04-01' = {
  name: 'default'
  properties: {
    tags: newTags
  }
}

@description('The name of the tags resource.')
output name string = tag.name

@description('The applied tags.')
output tags object = newTags

@description('The resource ID of the applied tags.')
output resourceId string = tag.id
