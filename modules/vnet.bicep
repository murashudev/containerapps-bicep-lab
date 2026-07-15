param location string
param vnetName string
param addressPrefix string

param subnetContainerAppsName string = 'containerapps'
param subnetContainerAppsPrefix string = '10.0.1.0/24'

param subnetMySqlName string = 'mysql'
param subnetMySqlPrefix string = '10.0.2.0/24'

param subnetPrivateEndpointName string = 'private-endpoint'
param subnetPrivateEndpointPrefix string = '10.0.3.0/24'

//
// NSG 名
//
param nsgContainerAppsName string = 'nsg-containerapps'
param nsgMySqlName string = 'nsg-mysql'
param nsgPrivateEndpointName string = 'nsg-private-endpoint'

//
// VNet 本体
//
resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
  }
}

//
// NSG: Container Apps サブネット用
// Font Door -> Container Apps の inbound のみ許可（例として 443 を許可）
// ※ Front Door の IP は後で main.bicep でパラメータ化して渡す想定
resource nsgContainerApps 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgContainerAppsName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-FrontDoor-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: 'AzureFrontDoor.Backend' // Front Door の IP アドレスに置き換える
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443' // Container Apps のポートに置き換える
        }
      }
    ]
  }
} 

//
// NSG: MySQL サブネット用
// Controller -> MySQL の接続のみ許可（3306）
resource nsgMySql 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgMySqlName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-Controller-Inbound'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'TCP'
          sourceAddressPrefix: subnetContainerAppsPrefix // Controller の IP アドレスに置き換える
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3306' // MySQL のポート
        }
      }
    ]
  }
}

//
// NSG: Private Endpoint サブネット用
// 必要に応じて制限（ここでは最小構成として空の NSG）
//
resource nsgPrivateEndpoint 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgPrivateEndpointName
  location: location
  properties: {
    securityRules: []
  }
}

//
// サブネット: Container Apps（delegation あり）
//
resource subnetContainerApps 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnet.name}/${subnetContainerAppsName}'
  properties: {
    addressPrefix: subnetContainerAppsPrefix
    networkSecurityGroup: {
      id: nsgContainerApps.id
    }
    delegations: [
      {
        name: 'containerapps-delegation'
        properties: {
          serviceName: 'Microsoft.App/environments'
        }
      }
    ]
  }
}

//
// サブネット: MySQL
//
resource subnetMySql 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnet.name}/${subnetMySqlName}'
  properties: {
    addressPrefix: subnetMySqlPrefix
    networkSecurityGroup: {
      id: nsgMySql.id
    }
  }
}

//
// サブネット: Private Endpoint
//
resource subnetPrivateEndpoint 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnet.name}/${subnetPrivateEndpointName}'
  properties: {
    addressPrefix: subnetPrivateEndpointPrefix
    networkSecurityGroup: {
      id: nsgPrivateEndpoint.id
    }
  }
}

//
// 出力
//
output vnetId string = vnet.id
output subnetContainerAppsId string = subnetContainerApps.id
output subnetMySqlId string = subnetMySql.id
output subnetPrivateEndpointId string = subnetPrivateEndpoint.id
