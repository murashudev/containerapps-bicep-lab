param location string = 'japaneast'

//
// VNet モジュールのパラメータ
//
param vnetName string = 'vnet-dev'
param addressPrefix string = '10.0.0.0/16'

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
// VNet モジュールの呼び出し
//
module vnet './modules/vnet.bicep' = {
  name: 'vnetModule'
  params: {
    location: location
    vnetName: vnetName
    addressPrefix: addressPrefix

    subnetContainerAppsName: subnetContainerAppsName
    subnetContainerAppsPrefix: subnetContainerAppsPrefix

    subnetMySqlName: subnetMySqlName
    subnetMySqlPrefix: subnetMySqlPrefix

    subnetPrivateEndpointName: subnetPrivateEndpointName
    subnetPrivateEndpointPrefix: subnetPrivateEndpointPrefix

    nsgContainerAppsName: nsgContainerAppsName
    nsgMySqlName: nsgMySqlName
    nsgPrivateEndpointName: nsgPrivateEndpointName
  }
}

//
// 出力（確認用）
//
output vnetId string = vnet.outputs.vnetId
output subnetContainerAppsId string = vnet.outputs.subnetContainerAppsId
output subnetMySqlId string = vnet.outputs.subnetMySqlId
output subnetPrivateEndpointId string = vnet.outputs.subnetPrivateEndpointId
