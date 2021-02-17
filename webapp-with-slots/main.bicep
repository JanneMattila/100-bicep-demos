param appName string = 'contoso00000000020'
param location string = 'north europe'
param deployProductionSite bool = true

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: 'asp'
  location: location
  kind: 'linux'
  sku: {
    name: 'S1'
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = if (deployProductionSite) {
  name: appName
  location: location
  kind: 'web'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      ftpsState: 'Disabled'
      healthCheckPath: '/'

      linuxFxVersion: 'DOCKER|jannemattila/webapp-update:1.0.3'
      appSettings: [
        {
          name: 'AppEnvironment'
          value: 'Banana'
        }
        {
          name: 'AppEnvironmentSticky'
          value: 'Banana'
        }
        {
          name: 'WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG'
          value: '1'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_PATH'
          value: '/'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_STATUSES'
          value: '200'
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

resource config 'Microsoft.Web/sites/config@2020-06-01' = {
  name: '${appName}/slotConfigNames'
  location: location
  properties: {
    appSettingNames: [
      'AppEnvironmentSticky'
    ]
  }
}

resource slot 'Microsoft.Web/sites/slots@2020-06-01' = {
  name: '${appName}/staging'
  location: location
  kind: 'web'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      alwaysOn: true
      http20Enabled: true
      ftpsState: 'Disabled'
      healthCheckPath: '/'

      linuxFxVersion: 'DOCKER|jannemattila/webapp-update:1.0.3'
      appSettings: [
        {
          name: 'AppEnvironment'
          value: 'Orange'
        }
        {
          name: 'AppEnvironmentSticky'
          value: 'Orange'
        }
        {
          name: 'WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG'
          value: '1'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_PATH'
          value: '/'
        }
        {
          name: 'WEBSITE_SWAP_WARMUP_PING_STATUSES'
          value: '200'
        }
      ]
    }
    serverFarmId: appServicePlan.id
    httpsOnly: true
    clientAffinityEnabled: false
  }
}

//
// Swap-AzWebAppSlot -ResourceGroupName "rg-bicep-slots" `
//   -Name "contoso00000000020" `
//   -SourceSlotName "staging" `
//   -DestinationSlotName Production
//