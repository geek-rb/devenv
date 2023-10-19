@description('The location of all resources')
param location string = resourceGroup().location

@description('The vnet name')
param vnetName string = 'test_vnet'

@description('The vnet rg')
param vnetRg string = 'epmc-rg-devenv-acm32'

@description('The vnet spoke prefix')
param subnetPrefix string = '10.10.200.0/29'


var subnetName = 'devSubnet-${replace(split(subnetPrefix, '.')[3], '/', '-')}'

var vmName = 'vm-${subnetName}'


@description('The username for the Virtual Machine')
param adminUsername string = 'newuser'

@description('The password for the Virtual Machine')
param adminUsername2 string = '-7v7zrTffbF8'

// subnet
module subnet_add 'vnet.bicep' = {
  name: 'vnetModule-deployment'
  scope: resourceGroup(subscription().id, vnetRg)
  params: {
    vnetName: vnetName
    subnetName: subnetName
    subnetPrefix: subnetPrefix
  }
}

// VM with vnic
resource vmNic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: '${vmName}-ipconfig-01'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet_add.outputs.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-07-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminUsername2
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-os-01'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: vmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
