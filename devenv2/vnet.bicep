@description('The existing vnet')
param vnetName string

@description('The new subnet name')
param subnetName string

@description('The vnet spoke prefix')
param subnetPrefix string


resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: subnetPrefix
  }
}

@description('The output subnet id')
output id string = subnet.id
