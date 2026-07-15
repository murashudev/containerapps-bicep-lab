# 📘 02_vnet-and-subnets.md  
Azure Container Apps 基盤のネットワーク構築（VNet＋サブネット＋NSG）

---

## 🎯 目的  
この章では、Azure Container Apps を VNet 統合して利用するための  
**ネットワーク基盤（VNet・サブネット・NSG）を Bicep で構築する**。

構築する内容は以下のとおり：

- VNet（10.0.0.0/16）
- サブネット 3つ  
  - containerapps（delegation: Microsoft.App/environments）  
  - mysql  
  - private-endpoint  
- NSG 3つ  
  - containerapps 用（Front Door inbound 許可）  
  - mysql 用（Container Apps → MySQL 許可）  
  - private-endpoint 用（最小構成）

---

## 📁 完成するネットワーク構成

```
vnet-dev (10.0.0.0/16)
├─ containerapps (10.0.1.0/24)
│   └─ delegation: Microsoft.App/environments
n│   └─ NSG: nsg-containerapps
├─ mysql (10.0.2.0/24)
│   └─ NSG: nsg-mysql
└─ private-endpoint (10.0.3.0/24)
    └─ NSG: nsg-private-endpoint
```

---

## 🧱 Bicep コード（modules/vnet.bicep）

以下は第2章で実装した **完全動作版の vnet.bicep**。

```
param location string
param vnetName string = 'vnet-dev'
param addressPrefix string = '10.0.0.0/16'

param subnetContainerAppsName string = 'containerapps'
param subnetContainerAppsPrefix string = '10.0.1.0/24'

param subnetMySqlName string = 'mysql'
param subnetMySqlPrefix string = '10.0.2.0/24'

param subnetPrivateEndpointName string = 'private-endpoint'
param subnetPrivateEndpointPrefix string = '10.0.3.0/24'

param nsgContainerAppsName string = 'nsg-containerapps'
param nsgMySqlName string = 'nsg-mysql'
param nsgPrivateEndpointName string = 'nsg-private-endpoint'

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

resource nsgContainerApps 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgContainerAppsName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-FrontDoor-HTTPS'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureFrontDoor.Backend'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

resource nsgMySql 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgMySqlName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-ContainerApps-MySQL'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: subnetContainerAppsPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3306'
        }
      }
    ]
  }
}

resource nsgPrivateEndpoint 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgPrivateEndpointName
  location: location
  properties: {
    securityRules: []
  }
}

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

resource subnetMySql 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnet.name}/${subnetMySqlName}'
  properties: {
    addressPrefix: subnetMySqlPrefix
    networkSecurityGroup: {
      id: nsgMySql.id
    }
  }
}

resource subnetPrivateEndpoint 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnet.name}/${subnetPrivateEndpointName}'
  properties: {
    addressPrefix: subnetPrivateEndpointPrefix
    networkSecurityGroup: {
      id: nsgPrivateEndpoint.id
    }
  }
}

output vnetId string = vnet.id
output subnetContainerAppsId string = subnetContainerApps.id
output subnetMySqlId string = subnetMySql.id
output subnetPrivateEndpointId string = subnetPrivateEndpoint.id
```

---

## 🧱 main.bicep への組み込み

```
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
```

---

## 🚀 デプロイ手順

### 1. Resource Group を Bicep（subscription デプロイ）で作成

```
az deployment sub create `
  --location japaneast `
  --template-file subscription/rg.bicep `
  --parameters rgName='rg-dev' location='japaneast'
```

### 2. main.bicep を group デプロイ

```
az deployment group create `
  --resource-group rg-dev `
  --template-file main.bicep
```

---

## 🔍 Azure Portal で確認する内容

- vnet-dev が作成されている  
- サブネットが 3 つできている  
- containerapps サブネットに delegation が付いている  
- NSG が 3 つできている  
- サブネットに NSG が紐付いている  

すべて確認できれば **第2章は完了**。

---

## 🧩 第2章で遭遇したエラーと修正内容（重要）

### ❌ NSG の SourcePortRange が必須になっていた  
→ `sourcePortRange: '*'` を追加して解決

### ❌ delegation の serviceName が誤っていた  
誤：`Microsoft.Web/containerApps`  
正：`Microsoft.App/environments`

→ 最新仕様に合わせて修正し、デプロイ成功

---

## 🎉 完了  
これで **ネットワーク基盤（VNet＋サブネット＋NSG）** が完全に構築できました。  
次章では、Container Apps Environment を VNet 統合して構築します。

---

## 🧭 次のステップ（Guided Links）
- **Container Apps Environment の Bicep を作成したい**  
- **main.bicep に Environment モジュールを追加したい**  
