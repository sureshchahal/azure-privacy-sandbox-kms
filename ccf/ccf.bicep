param location string
param registry string
param tag string
param managedIDGroup string = resourceGroup().name
param managedIDName string
param ccePolicy string

var nodeId = 'ccf-node-${deployment().name}'

resource ccfNode 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: nodeId
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId(managedIDGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIDName)}': {}
    }
  }
  properties: {
    osType: 'Linux'
    sku: 'Confidential'
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          port: 8080
          protocol: 'TCP'
        }
      ]
      type: 'Public'
      dnsNameLabel: nodeId
    }
    confidentialComputeProperties: {
      ccePolicy: ccePolicy
    }
    imageRegistryCredentials: [
      {
        server: registry
        identity: resourceId(managedIDGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIDName)
      }
    ]
    containers: [
      {
        name: 'ccf-node'
        properties: {
          image: '${registry}/ccf/snp:${tag}'
          ports: [
            {
              port: 8080
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
          command: [
            'bash'
            '-c'
            '/usr/bin/cchost --config /app/cchost_config_snp.json'
            // join([
            //   'export UVM_SECURITY_CONTEXT_DIR=$UVM_SECURITY_CONTEXT_DIR &&'
            //   '/usr/bin/cchost --config /app/cchost_config_snp.json'
            // ], ' ')
          ]
        }
      }
    ]
  }
}

output ids array = [
  ccfNode.id
]
