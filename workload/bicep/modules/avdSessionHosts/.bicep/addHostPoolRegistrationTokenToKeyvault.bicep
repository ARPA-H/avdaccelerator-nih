targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
// @sys.description('Data colleciton rule association name.')
// param name string

@sys.description('VM name.')
@sys.secure()
param hostPoolRegistrationToken string


@sys.description('VM name.')
param keyVaultName string

// =========== //
// Deployments //
// =========== //
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Create new secret in the Key Vault to store the host pool registration token
resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'hostPoolRegistrationToken'
  properties: {
    value: hostPoolRegistrationToken
  }
}
