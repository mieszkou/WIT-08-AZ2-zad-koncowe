**********************
PowerShell transcript start
Start time: 20230602223250
Username: Mi3-PC\Mieszko
RunAs User: Mi3-PC\Mieszko
Configuration Name: 
Machine: MI3-PC (Microsoft Windows NT 10.0.22621.0)
Host Application: C:\Program Files\PowerShell\7\pwsh.dll -WorkingDirectory ~
Process ID: 29356
PSVersion: 7.3.4
PSEdition: Core
GitCommitId: 7.3.4
OS: Microsoft Windows 10.0.22621
Platform: Win32NT
PSCompatibleVersions: 1.0, 2.0, 3.0, 4.0, 5.0, 5.1.10032.0, 6.0.0, 6.1.0, 6.2.0, 7.0.0, 7.1.0, 7.2.0, 7.3.4
PSRemotingProtocolVersion: 2.3
SerializationVersion: 1.1.0.1
WSManStackVersion: 3.0
**********************
Transcript started, output file is .\testyms.ps1
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$rg = @{
    Name = 'CreatePubLBQS-rg'
    Location = 'eastus'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>New-AzResourceGroup @rg

ResourceGroupName : CreatePubLBQS-rg
Location          : eastus
ProvisioningState : Succeeded
Tags              : 
ResourceId        : /subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg


E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$rg = @{
    Name = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>New-AzResourceGroup @rg

ResourceGroupName : CreatePubLBQS-rg
Location          : polandcentral
ProvisioningState : Succeeded
Tags              : 
ResourceId        : /subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg


E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$publicip = @{
    Name = 'myPublicIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    Sku = 'Standard'
    AllocationMethod = 'static'
    Zone = 1,2,3
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>New-AzPublicIpAddress @publicip
WARNING: Upcoming breaking changes in the cmdlet 'New-AzPublicIpAddress' :
Default behaviour of Zone will be changed
Cmdlet invocation changes :
    Old Way : Sku = Standard means the Standard Public IP is zone-redundant.
    New Way : Sku = Standard and Zone = {} means the Standard Public IP has no zones. If you want to create a zone-redundant Public IP address, please specify all the zones in the region. For example, Zone = ['1', '2', '3'].
It is recommended to use parameter '-Sku Standard' to create new IP address. Please note that it will become the default behavior for IP address creation in the future.
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.

Name                     : myPublicIP
ResourceGroupName        : CreatePubLBQS-rg
Location                 : polandcentral
Id                       : /subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/provider
                           s/Microsoft.Network/publicIPAddresses/myPublicIP
Etag                     : W/"1a353b81-4355-4ce6-9435-58727687aaf4"
ResourceGuid             : 9e6af7e4-3df5-40c7-b3ae-de7fd99599c4
ProvisioningState        : Succeeded
Tags                     : 
PublicIpAllocationMethod : Static
IpAddress                : 20.215.176.225
PublicIpAddressVersion   : IPv4
IdleTimeoutInMinutes     : 4
IpConfiguration          : null
DnsSettings              : null
DdosSettings             : {
                             "ProtectionMode": "VirtualNetworkInherited"
                           }
Zones                    : {1, 2, 3}
Sku                      : {
                             "Name": "Standard",
                             "Tier": "Regional"
                           }
IpTags                   : []
ExtendedLocation         : null


E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Place public IP created in previous steps into variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$pip = @{
    Name = 'myPublicIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$publicIp = Get-AzPublicIpAddress @pip
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create load balancer frontend configuration and place in variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$fip = @{
    Name = 'myFrontEnd'
    PublicIpAddress = $publicIp 
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$feip = New-AzLoadBalancerFrontendIpConfig @fip
WARNING: Upcoming breaking changes in the cmdlet 'New-AzLoadBalancerFrontendIpConfig' :
Default behaviour of Zone will be changed
Cmdlet invocation changes :
    Old Way : Sku = Standard means the Standard FrontendIpConfig is zone-redundant.
    New Way : Sku = Standard and Zone = {} means the Standard FrontendIpConfig has no zones. If you want to create a zone-redundant FrontendIpConfig, please specify all the zones in the region. For example, Zone = ['1', '2', '3'].
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create backend address pool configuration and place in variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$bepool = New-AzLoadBalancerBackendAddressPoolConfig -Name 'myBackEndPool'
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create the health probe and place in variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$probe = @{
    Name = 'myHealthProbe'
    Protocol = 'tcp'
    Port = '80'
    IntervalInSeconds = '360'
    ProbeCount = '5'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$healthprobe = New-AzLoadBalancerProbeConfig @probe
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create the load balancer rule and place in variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$lbrule = @{
    Name = 'myHTTPRule'
    Protocol = 'tcp'
    FrontendPort = '80'
    BackendPort = '80'
    IdleTimeoutInMinutes = '15'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bePool
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$rule = New-AzLoadBalancerRuleConfig @lbrule -EnableTcpReset -DisableOutboundSNAT
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create the load balancer resource. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$loadbalancer = @{
    ResourceGroupName = 'CreatePubLBQS-rg'
    Name = 'myLoadBalancer'
    Location = 'polandcentral'
    Sku = 'Standard'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bePool
    LoadBalancingRule = $rule
    Probe = $healthprobe
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>New-AzLoadBalancer @loadbalancer
WARNING: Upcoming breaking changes in the cmdlet 'New-AzLoadBalancer' :
It is recommended to use parameter '-Sku Standard' to create new Load Balancer. Please note that it will become the default behavior for Load Balancer creation in the future.
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.

Name                     : myLoadBalancer
ResourceGroupName        : CreatePubLBQS-rg
Location                 : polandcentral
Id                       : /subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/provider
                           s/Microsoft.Network/loadBalancers/myLoadBalancer
Etag                     : W/"7ce607aa-65bd-4f68-a315-3ef8f48b22d8"
ResourceGuid             : 45bbe26b-ead8-468b-8d9c-3b13d9ec1323
ProvisioningState        : Succeeded
Tags                     : 
FrontendIpConfigurations : [
                             {
                               "Name": "myFrontEnd",
                               "Etag": "W/\"7ce607aa-65bd-4f68-a315-3ef8f48b22d8\"",
                               "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-
                           rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/frontendIPConfigurations/myFront
                           End",
                               "PrivateIpAllocationMethod": "Dynamic",
                               "ProvisioningState": "Succeeded",
                               "Zones": [],
                               "InboundNatRules": [],
                               "InboundNatPools": [],
                               "OutboundRules": [],
                               "LoadBalancingRules": [
                                 {
                                   "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubL
                           BQS-rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/loadBalancingRules/myHTTPRul
                           e"
                                 }
                               ],
                               "PublicIpAddress": {
                                 "DdosSettings": {},
                                 "IpTags": [],
                                 "Zones": [],
                                 "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQ
                           S-rg/providers/Microsoft.Network/publicIPAddresses/myPublicIP"
                               }
                             }
                           ]
BackendAddressPools      : [
                             {
                               "Name": "myBackEndPool",
                               "Etag": "W/\"7ce607aa-65bd-4f68-a315-3ef8f48b22d8\"",
                               "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-
                           rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/backendAddressPools/myBackEndPoo
                           l",
                               "ProvisioningState": "Succeeded",
                               "BackendIpConfigurations": [],
                               "LoadBalancerBackendAddresses": [],
                               "LoadBalancingRules": [
                                 {
                                   "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubL
                           BQS-rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/loadBalancingRules/myHTTPRul
                           e"
                                 }
                               ],
                               "TunnelInterfaces": []
                             }
                           ]
LoadBalancingRules       : [
                             {
                               "Name": "myHTTPRule",
                               "Etag": "W/\"7ce607aa-65bd-4f68-a315-3ef8f48b22d8\"",
                               "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-
                           rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/loadBalancingRules/myHTTPRule",
                               "Protocol": "Tcp",
                               "LoadDistribution": "Default",
                               "FrontendPort": 80,
                               "BackendPort": 80,
                               "IdleTimeoutInMinutes": 15,
                               "EnableFloatingIP": false,
                               "EnableTcpReset": true,
                               "DisableOutboundSNAT": true,
                               "ProvisioningState": "Succeeded",
                               "FrontendIPConfiguration": {
                                 "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQ
                           S-rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/frontendIPConfigurations/myFro
                           ntEnd"
                               },
                               "BackendAddressPool": {
                                 "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQ
                           S-rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/backendAddressPools/myBackEndP
                           ool"
                               },
                               "BackendAddressPools": [
                                 {
                                   "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubL
                           BQS-rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/backendAddressPools/myBackEn
                           dPool"
                                 }
                               ]
                             }
                           ]
Probes                   : [
                             {
                               "Name": "myHealthProbe",
                               "Etag": "W/\"7ce607aa-65bd-4f68-a315-3ef8f48b22d8\"",
                               "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-
                           rg/providers/Microsoft.Network/loadBalancers/myLoadBalancer/probes/myHealthProbe",
                               "Protocol": "Tcp",
                               "Port": 80,
                               "IntervalInSeconds": 360,
                               "NumberOfProbes": 5,
                               "ProbeThreshold": 1,
                               "ProvisioningState": "Succeeded",
                               "LoadBalancingRules": []
                             }
                           ]
InboundNatRules          : []
InboundNatPools          : []
Sku                      : {
                             "Name": "Standard",
                             "Tier": "Regional"
                           }
ExtendedLocation         : null


E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create public IP address for NAT gateway ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$ip = @{
    Name = 'myNATgatewayIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    Sku = 'Standard'
    AllocationMethod = 'Static'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$publicIP = New-AzPublicIpAddress @ip
WARNING: Upcoming breaking changes in the cmdlet 'New-AzPublicIpAddress' :
Default behaviour of Zone will be changed
Cmdlet invocation changes :
    Old Way : Sku = Standard means the Standard Public IP is zone-redundant.
    New Way : Sku = Standard and Zone = {} means the Standard Public IP has no zones. If you want to create a zone-redundant Public IP address, please specify all the zones in the region. For example, Zone = ['1', '2', '3'].
It is recommended to use parameter '-Sku Standard' to create new IP address. Please note that it will become the default behavior for IP address creation in the future.
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create NAT gateway resource ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$nat = @{
    ResourceGroupName = 'CreatePubLBQS-rg'
    Name = 'myNATgateway'
    IdleTimeoutInMinutes = '10'
    Sku = 'Standard'
    Location = 'polandcentral'
    PublicIpAddress = $publicIP
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$natGateway = New-AzNatGateway @nat
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create backend subnet config ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$subnet = @{
    Name = 'myBackendSubnet'
    AddressPrefix = '10.1.0.0/24'
    NatGateway = $natGateway
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$subnetConfig = New-AzVirtualNetworkSubnetConfig @subnet 
WARNING: Upcoming breaking changes in the cmdlet 'New-AzVirtualNetworkSubnetConfig' :
Update Property Name
Cmdlet invocation changes :
    Old Way : -ResourceId
    New Way : -NatGatewayId
Update Property Name
Cmdlet invocation changes :
    Old Way : -InputObject
    New Way : -NatGateway
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create Azure Bastion subnet. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$bastsubnet = @{
    Name = 'AzureBastionSubnet' 
    AddressPrefix = '10.1.1.0/24'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$bastsubnetConfig = New-AzVirtualNetworkSubnetConfig @bastsubnet
WARNING: Upcoming breaking changes in the cmdlet 'New-AzVirtualNetworkSubnetConfig' :
Update Property Name
Cmdlet invocation changes :
    Old Way : -ResourceId
    New Way : -NatGatewayId
Update Property Name
Cmdlet invocation changes :
    Old Way : -InputObject
    New Way : -NatGateway
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create the virtual network ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$net = @{
    Name = 'myVNet'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    AddressPrefix = '10.1.0.0/16'
    Subnet = $subnetConfig,$bastsubnetConfig
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$vnet = New-AzVirtualNetwork @net
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create public IP address for bastion host. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$ip = @{
    Name = 'myBastionIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    Sku = 'Standard'
    AllocationMethod = 'Static'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$publicip = New-AzPublicIpAddress @ip
WARNING: Upcoming breaking changes in the cmdlet 'New-AzPublicIpAddress' :
Default behaviour of Zone will be changed
Cmdlet invocation changes :
    Old Way : Sku = Standard means the Standard Public IP is zone-redundant.
    New Way : Sku = Standard and Zone = {} means the Standard Public IP has no zones. If you want to create a zone-redundant Public IP address, please specify all the zones in the region. For example, Zone = ['1', '2', '3'].
It is recommended to use parameter '-Sku Standard' to create new IP address. Please note that it will become the default behavior for IP address creation in the future.
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create bastion host ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$bastion = @{
    ResourceGroupName = 'CreatePubLBQS-rg'
    Name = 'myBastion'
    PublicIpAddress = $publicip
    VirtualNetwork = $vnet
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>New-AzBastion @bastion -AsJob

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create rule for network security group and place in variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$nsgrule = @{
    Name = 'myNSGRuleHTTP'
    Description = 'Allow HTTP'
    Protocol = '*'
    SourcePortRange = '*'
    DestinationPortRange = '80'
    SourceAddressPrefix = 'Internet'
    DestinationAddressPrefix = '*'
    Access = 'Allow'
    Priority = '2000'
    Direction = 'Inbound'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$rule1 = New-AzNetworkSecurityRuleConfig @nsgrule
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Create network security group ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$nsg = @{
    Name = 'myNSG'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    SecurityRules = $rule1
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>New-AzNetworkSecurityGroup @nsg

Name                 : myNSG
ResourceGroupName    : CreatePubLBQS-rg
Location             : polandcentral
Id                   : /subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/providers/Mi
                       crosoft.Network/networkSecurityGroups/myNSG
Etag                 : W/"2f323198-392a-4804-b911-52dd2e81d17f"
ResourceGuid         : b51c584f-5716-4501-95a4-174fe6a281c7
ProvisioningState    : Succeeded
Tags                 : 
FlushConnection      : false
SecurityRules        : [
                         {
                           "Name": "myNSGRuleHTTP",
                           "Etag": "W/\"2f323198-392a-4804-b911-52dd2e81d17f\"",
                           "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/p
                       roviders/Microsoft.Network/networkSecurityGroups/myNSG/securityRules/myNSGRuleHTTP",
                           "Description": "Allow HTTP",
                           "Protocol": "*",
                           "SourcePortRange": [
                             "*"
                           ],
                           "DestinationPortRange": [
                             "80"
                           ],
                           "SourceAddressPrefix": [
                             "Internet"
                           ],
                           "DestinationAddressPrefix": [
                             "*"
                           ],
                           "Access": "Allow",
                           "Priority": 2000,
                           "Direction": "Inbound",
                           "ProvisioningState": "Succeeded",
                           "SourceApplicationSecurityGroups": [],
                           "DestinationApplicationSecurityGroups": []
                         }
                       ]
DefaultSecurityRules : [
                         {
                           "Name": "AllowVnetInBound",
                           "Etag": "W/\"2f323198-392a-4804-b911-52dd2e81d17f\"",
                           "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/p
                       roviders/Microsoft.Network/networkSecurityGroups/myNSG/defaultSecurityRules/AllowVnetInBound",
                           "Description": "Allow inbound traffic from all VMs in VNET",
                           "Protocol": "*",
                           "SourcePortRange": [
                             "*"
                           ],
                           "DestinationPortRange": [
                             "*"
                           ],
                           "SourceAddressPrefix": [
                             "VirtualNetwork"
                           ],
                           "DestinationAddressPrefix": [
                             "VirtualNetwork"
                           ],
                           "Access": "Allow",
                           "Priority": 65000,
                           "Direction": "Inbound",
                           "ProvisioningState": "Succeeded",
                           "SourceApplicationSecurityGroups": [],
                           "DestinationApplicationSecurityGroups": []
                         },
                         {
                           "Name": "AllowAzureLoadBalancerInBound",
                           "Etag": "W/\"2f323198-392a-4804-b911-52dd2e81d17f\"",
                           "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/p
                       roviders/Microsoft.Network/networkSecurityGroups/myNSG/defaultSecurityRules/AllowAzureLoadBalanc
                       erInBound",
                           "Description": "Allow inbound traffic from azure load balancer",
                           "Protocol": "*",
                           "SourcePortRange": [
                             "*"
                           ],
                           "DestinationPortRange": [
                             "*"
                           ],
                           "SourceAddressPrefix": [
                             "AzureLoadBalancer"
                           ],
                           "DestinationAddressPrefix": [
                             "*"
                           ],
                           "Access": "Allow",
                           "Priority": 65001,
                           "Direction": "Inbound",
                           "ProvisioningState": "Succeeded",
                           "SourceApplicationSecurityGroups": [],
                           "DestinationApplicationSecurityGroups": []
                         },
                         {
                           "Name": "DenyAllInBound",
                           "Etag": "W/\"2f323198-392a-4804-b911-52dd2e81d17f\"",
                           "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/p
                       roviders/Microsoft.Network/networkSecurityGroups/myNSG/defaultSecurityRules/DenyAllInBound",
                           "Description": "Deny all inbound traffic",
                           "Protocol": "*",
                           "SourcePortRange": [
                             "*"
                           ],
                           "DestinationPortRange": [
                             "*"
                           ],
                           "SourceAddressPrefix": [
                             "*"
                           ],
                           "DestinationAddressPrefix": [
                             "*"
                           ],
                           "Access": "Deny",
                           "Priority": 65500,
                           "Direction": "Inbound",
                           "ProvisioningState": "Succeeded",
                           "SourceApplicationSecurityGroups": [],
                           "DestinationApplicationSecurityGroups": []
                         },
                         {
                           "Name": "AllowVnetOutBound",
                           "Etag": "W/\"2f323198-392a-4804-b911-52dd2e81d17f\"",
                           "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/p
                       roviders/Microsoft.Network/networkSecurityGroups/myNSG/defaultSecurityRules/AllowVnetOutBound",
                           "Description": "Allow outbound traffic from all VMs to all VMs in VNET",
                           "Protocol": "*",
                           "SourcePortRange": [
                             "*"
                           ],
                           "DestinationPortRange": [
                             "*"
                           ],
                           "SourceAddressPrefix": [
                             "VirtualNetwork"
                           ],
                           "DestinationAddressPrefix": [
                             "VirtualNetwork"
                           ],
                           "Access": "Allow",
                           "Priority": 65000,
                           "Direction": "Outbound",
                           "ProvisioningState": "Succeeded",
                           "SourceApplicationSecurityGroups": [],
                           "DestinationApplicationSecurityGroups": []
                         },
                         {
                           "Name": "AllowInternetOutBound",
                           "Etag": "W/\"2f323198-392a-4804-b911-52dd2e81d17f\"",
                           "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/p
                       roviders/Microsoft.Network/networkSecurityGroups/myNSG/defaultSecurityRules/AllowInternetOutBoun
                       d",
                           "Description": "Allow outbound traffic from all VMs to Internet",
                           "Protocol": "*",
                           "SourcePortRange": [
                             "*"
                           ],
                           "DestinationPortRange": [
                             "*"
                           ],
                           "SourceAddressPrefix": [
                             "*"
                           ],
                           "DestinationAddressPrefix": [
                             "Internet"
                           ],
                           "Access": "Allow",
                           "Priority": 65001,
                           "Direction": "Outbound",
                           "ProvisioningState": "Succeeded",
                           "SourceApplicationSecurityGroups": [],
                           "DestinationApplicationSecurityGroups": []
                         },
                         {
                           "Name": "DenyAllOutBound",
                           "Etag": "W/\"2f323198-392a-4804-b911-52dd2e81d17f\"",
                           "Id": "/subscriptions/c9bc5a7b-b565-446f-aa98-e2fe85c4564d/resourceGroups/CreatePubLBQS-rg/p
                       roviders/Microsoft.Network/networkSecurityGroups/myNSG/defaultSecurityRules/DenyAllOutBound",
                           "Description": "Deny all outbound traffic",
                           "Protocol": "*",
                           "SourcePortRange": [
                             "*"
                           ],
                           "DestinationPortRange": [
                             "*"
                           ],
                           "SourceAddressPrefix": [
                             "*"
                           ],
                           "DestinationAddressPrefix": [
                             "*"
                           ],
                           "Access": "Deny",
                           "Priority": 65500,
                           "Direction": "Outbound",
                           "ProvisioningState": "Succeeded",
                           "SourceApplicationSecurityGroups": [],
                           "DestinationApplicationSecurityGroups": []
                         }
                       ]
NetworkInterfaces    : []
Subnets              : []


E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS># Set the administrator and password for the VMs. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$cred = Get-Credential
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Place the virtual network into a variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$net = @{
    Name = 'myVNet'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$vnet = Get-AzVirtualNetwork @net
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Place the load balancer into a variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$lb = @{
    Name = 'myLoadBalancer'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$bepool = Get-AzLoadBalancer @lb  | Get-AzLoadBalancerBackendAddressPoolConfig
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## Place the network security group into a variable. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$ns = @{
    Name = 'myNSG'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>$nsg = Get-AzNetworkSecurityGroup @ns
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>## For loop with variable to create virtual machines for load balancer backend pool. ##
E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>for ($i=1; $i -le 2; $i++){

    ## Command to create network interface for VMs ##
    $nic = @{
        Name = "myNicVM$i"
        ResourceGroupName = 'CreatePubLBQS-rg'
        Location = 'polandcentral'
        Subnet = $vnet.Subnets[0]
        NetworkSecurityGroup = $nsg
        LoadBalancerBackendAddressPool = $bepool
    }
    $nicVM = New-AzNetworkInterface @nic

    ## Create a virtual machine configuration for VMs ##
    $vmsz = @{
        VMName = "myVM$i"
        VMSize = 'Standard_DS1_v2'  
    }
    $vmos = @{
        ComputerName = "myVM$i"
        Credential = $cred
    }
    $vmimage = @{
        PublisherName = 'MicrosoftWindowsServer'
        Offer = 'WindowsServer'
        Skus = '2019-Datacenter'
        Version = 'latest'    
    }
    $vmConfig = New-AzVMConfig @vmsz `
        | Set-AzVMOperatingSystem @vmos -Windows `
        | Set-AzVMSourceImage @vmimage `
        | Add-AzVMNetworkInterface -Id $nicVM.Id

    ## Create the virtual machine for VMs ##
    $vm = @{
        ResourceGroupName = 'CreatePubLBQS-rg'
        Location = 'polandcentral'
        VM = $vmConfig
        Zone = "$i"
    }
    New-AzVM @vm -AsJob
}
WARNING: Upcoming breaking changes in the cmdlet 'New-AzVM' :
Consider using the image alias including the version of the distribution you want to use in the "-Image" parameter of the "New-AzVM" cmdlet. On April 30, 2023, the image deployed using `UbuntuLTS` will reach its end of life.
Starting in May 2023 the "New-AzVM" cmdlet will deploy with the Trusted Launch configuration by default. To know more about Trusted Launch, please visit https://docs.microsoft.com/en-us/azure/virtual-machines/trusted-launch
It is recommended to use parameter "-PublicIpSku Standard" in order to create a new VM with a Standard public IP.Specifying zone(s) using the "-Zone" parameter will also result in a Standard public IP.If "-Zone" and "-PublicIpSku" are not specified, the VM will be created with a Basic public IP instead.Please note that the Standard SKU IPs will become the default behavior for VM creation in the future
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
2      Long Running O… AzureLongRunni… Running       True            localhost            New-AzVM
WARNING: Upcoming breaking changes in the cmdlet 'New-AzVM' :
Consider using the image alias including the version of the distribution you want to use in the "-Image" parameter of the "New-AzVM" cmdlet. On April 30, 2023, the image deployed using `UbuntuLTS` will reach its end of life.
Starting in May 2023 the "New-AzVM" cmdlet will deploy with the Trusted Launch configuration by default. To know more about Trusted Launch, please visit https://docs.microsoft.com/en-us/azure/virtual-machines/trusted-launch
It is recommended to use parameter "-PublicIpSku Standard" in order to create a new VM with a Standard public IP.Specifying zone(s) using the "-Zone" parameter will also result in a Standard public IP.If "-Zone" and "-PublicIpSku" are not specified, the VM will be created with a Basic public IP instead.Please note that the Standard SKU IPs will become the default behavior for VM creation in the future
Note : Go to https://aka.ms/azps-changewarnings for steps to suppress this breaking change warning, and other information on breaking changes in Azure PowerShell.
3      Long Running O… AzureLongRunni… Running       True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Running       True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Failed        True            localhost            New-AzVM

E:\Szkola\08-AZ2\WIT-08-AZ2-zad-koncowe>
PS>Stop-Transcript
**********************
PowerShell transcript end
End time: 20230602224550
**********************
