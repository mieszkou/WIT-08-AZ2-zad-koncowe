# Zadanie końcowe AZ2:

Liczba punktów: 20pkt

## Twoje zadanie:
Przygotuj skrypt, który wykona wdrożenie środowiska dla nowej aplikacji.

## Wymagania dotyczące skryptu:

Struktura katalogowa skryptu:

```
\numerindexu\nazwaskryptu.ps1
\numerindexu\log\log.txt
\numerindexu\raport.txt
\nuemrindexu\dane.txt
```

Podstawowe informację, które należy pobrać od użytkownika:

- numerIndexu
- Region: (Default może być ustawiony na North Europe)

Dane, które muszą być zapisane w zmiennych:

- Nazwa grupy zasobów: RG_numerIndexu
- Nazwa VM: VM-x-numerindexu
- Wielkość VM: jakaś mała VM-ka (dopracować)
- Nazwa storage account: mystorageacctplwit<NUMERINDEXU>
- TAG name: student = TAG wartość: <NUMERINDEXU>

Skrypt ma:

- pobierać wszystkie potrzebne informację od użytkownika lub ze zmiennych(nie hard kodujemy żadnych informacji w kodzie)
- obsługiwać błędy (np. 
- skrypt ma zawierać funkcję logowania zdarzeń do pliku (plik logu skryptu)
- skrypt ma zawierać komentarze, które opisują działanie poszczególnych sekcji kodu
- w skrypcie ma znajdować się 
  - blok zmiennych, 
  - blok z funkcjami i 
  - blok zwłaściwym skryptem

Działanie skryptu:

- utworzenie grupy zasobowej
- utworzenie VM z listy podanej w pliku dane.txt
  - w pliku dane.txt znajduję się nazwy co najmniej 2 VM-ek
- Tworzy usługę LB do której podłączone są tworzone VM-ki
- utworzenie storage account
- utworzy NSG podłączy do VM-eki zezwoli na ruch tylko z portu 80 i 443
- utworzenie grupy security dla zespołu, który będzie zarządzał projektem
  - przypisanie uprawnień grupie do grupy zasobów
- utworzenie raportu z listą wszystkich obiektów utworzonych dla projektu w wskazanej grupie zasobów z informacjami o TAGACH
- ostatni krok: usunie wszystkie obiekty, które zostały utworzone

Wymagania dotyczące sprawozdania:

- stronatytułowa
- spis treści
- spis ilustracji
- numerację stron
- cel laboratorium (treść zadania) i rozwiązanie podzielone na rozdziały
- Sprawozdanie ma być napisane jako dokumentacja rozwiązania, tak aby inna osoba po jego lekturze była wstanie odtworzyć zadanie

Jako odpowiedz/wynik wgraj:

- archiwum zip z plikami skryptu, logu i raportu(zachowując strukturę katalogową)
- sprawozdanie w pliku pdf
- Skrypt ma działać na różnych komputerach i na różnych subskrypcjach –jeżeli uruchomimy go na mojej VM w Azure, to ma zadziałać.

Punktacja:

Liczba punktów: 20pkt

5pkt -> sprawozdanie

1 pkt -> wymogi formalne

14 pkt -> skrypt i jego działanie

Uwaga, jeżeli skrypt nie zadziała w momencie sprawdzania: W sekcji: skrypt i jego działanie otrzymujemy 0 pkt



--------------



```
... One or more errors occurred. (Could not load type 'System.Security.Cryptography.SHA256Cng' from assembly 'System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'.) Connect-AzureAD: ....
```



## Create a resource group

```azurepowershell
$rg = @{
    Name = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
}
New-AzResourceGroup @rg
```

## Create a public IP address

```azurepowershell
$publicip = @{
    Name = 'myPublicIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    Sku = 'Standard'
    AllocationMethod = 'static'
    Zone = 1,2,3
}
New-AzPublicIpAddress @publicip
```

## Create a load balancer

This section details how you can create and configure the following components of the load balancer:

- Create a front-end IP with [New-AzLoadBalancerFrontendIpConfig](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azloadbalancerfrontendipconfig) for the frontend IP pool. This IP receives the incoming traffic on the load balancer
- Create a back-end address pool with [New-AzLoadBalancerBackendAddressPoolConfig](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azloadbalancerbackendaddresspoolconfig) for traffic sent from the frontend of the load balancer. This pool is where your backend virtual machines are deployed
- Create a health probe with [Add-AzLoadBalancerProbeConfig](https://learn.microsoft.com/en-us/powershell/module/az.network/add-azloadbalancerprobeconfig) that determines the health of the backend VM instances
- Create a load balancer rule with [Add-AzLoadBalancerRuleConfig](https://learn.microsoft.com/en-us/powershell/module/az.network/add-azloadbalancerruleconfig) that defines how traffic is distributed to the VMs
- Create a public load balancer with [New-AzLoadBalancer](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azloadbalancer)

```azurepowershell
## Place public IP created in previous steps into variable. ##
$pip = @{
    Name = 'myPublicIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
$publicIp = Get-AzPublicIpAddress @pip

## Create load balancer frontend configuration and place in variable. ##
$fip = @{
    Name = 'myFrontEnd'
    PublicIpAddress = $publicIp 
}
$feip = New-AzLoadBalancerFrontendIpConfig @fip

## Create backend address pool configuration and place in variable. ##
$bepool = New-AzLoadBalancerBackendAddressPoolConfig -Name 'myBackEndPool'

## Create the health probe and place in variable. ##
$probe = @{
    Name = 'myHealthProbe'
    Protocol = 'tcp'
    Port = '80'
    IntervalInSeconds = '360'
    ProbeCount = '5'
}
$healthprobe = New-AzLoadBalancerProbeConfig @probe

## Create the load balancer rule and place in variable. ##
$lbrule = @{
    Name = 'myHTTPRule'
    Protocol = 'tcp'
    FrontendPort = '80'
    BackendPort = '80'
    IdleTimeoutInMinutes = '15'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bePool
}
$rule = New-AzLoadBalancerRuleConfig @lbrule -EnableTcpReset -DisableOutboundSNAT

## Create the load balancer resource. ##
$loadbalancer = @{
    ResourceGroupName = 'CreatePubLBQS-rg'
    Name = 'myLoadBalancer'
    Location = 'polandcentral'
    Sku = 'Standard'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bePool
    LoadBalancingRule = $rule
    Probe = $healthprobe
}
New-AzLoadBalancer @loadbalancer
```



## Configure virtual network

Before you deploy VMs and test your load balancer, create the supporting virtual network resources.

Create a virtual network for the backend virtual machines.

Create a network security group to define inbound connections to your virtual network.

Create an Azure Bastion host to securely manage the virtual machines in the backend pool.

Use a NAT gateway to provide outbound internet access to resources in the backend pool of your load balancer.



### Create virtual network, network security group, bastion host, and NAT gateway

- Create a virtual network with [New-AzVirtualNetwork](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azvirtualnetwork)
- Create a network security group rule with [New-AzNetworkSecurityRuleConfig](https://learn.microsoft.com/en-us/powershell/module/az.network/new-aznetworksecurityruleconfig)
- Create an Azure Bastion host with [New-AzBastion](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azbastion)
- Create a network security group with [New-AzNetworkSecurityGroup](https://learn.microsoft.com/en-us/powershell/module/az.network/new-aznetworksecuritygroup)
- Create the NAT gateway resource with [New-AzNatGateway](https://learn.microsoft.com/en-us/powershell/module/az.network/new-aznatgateway)
- Use [New-AzVirtualNetworkSubnetConfig](https://learn.microsoft.com/en-us/powershell/module/az.network/new-azvirtualnetworksubnetconfig) to associate the NAT gateway to the subnet of the virtual network

Azure PowerShell

Open Cloudshell

```azurepowershell
## Create public IP address for NAT gateway ##
$ip = @{
    Name = 'myNATgatewayIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    Sku = 'Standard'
    AllocationMethod = 'Static'
}
$publicIP = New-AzPublicIpAddress @ip

## Create NAT gateway resource ##
$nat = @{
    ResourceGroupName = 'CreatePubLBQS-rg'
    Name = 'myNATgateway'
    IdleTimeoutInMinutes = '10'
    Sku = 'Standard'
    Location = 'polandcentral'
    PublicIpAddress = $publicIP
}
$natGateway = New-AzNatGateway @nat

## Create backend subnet config ##
$subnet = @{
    Name = 'myBackendSubnet'
    AddressPrefix = '10.1.0.0/24'
    NatGateway = $natGateway
}
$subnetConfig = New-AzVirtualNetworkSubnetConfig @subnet 

## Create Azure Bastion subnet. ##
$bastsubnet = @{
    Name = 'AzureBastionSubnet' 
    AddressPrefix = '10.1.1.0/24'
}
$bastsubnetConfig = New-AzVirtualNetworkSubnetConfig @bastsubnet

## Create the virtual network ##
$net = @{
    Name = 'myVNet'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    AddressPrefix = '10.1.0.0/16'
    Subnet = $subnetConfig,$bastsubnetConfig
}
$vnet = New-AzVirtualNetwork @net

## Create public IP address for bastion host. ##
$ip = @{
    Name = 'myBastionIP'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    Sku = 'Standard'
    AllocationMethod = 'Static'
}
$publicip = New-AzPublicIpAddress @ip

## Create bastion host ##
$bastion = @{
    ResourceGroupName = 'CreatePubLBQS-rg'
    Name = 'myBastion'
    PublicIpAddress = $publicip
    VirtualNetwork = $vnet
}
New-AzBastion @bastion

## Create rule for network security group and place in variable. ##
$nsgrule = @{
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
$rule1 = New-AzNetworkSecurityRuleConfig @nsgrule

## Create network security group ##
$nsg = @{
    Name = 'myNSG'
    ResourceGroupName = 'CreatePubLBQS-rg'
    Location = 'polandcentral'
    SecurityRules = $rule1
}
New-AzNetworkSecurityGroup @nsg
```



## Create virtual machines

In this section, you create the two virtual machines for the backend pool of the load balancer.

- Create two network interfaces with [New-AzNetworkInterface](https://learn.microsoft.com/en-us/powershell/module/az.network/new-aznetworkinterface)
- Set an administrator username and password for the VMs with [Get-Credential](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-credential)
- Create the virtual machines with:
  - [New-AzVM](https://learn.microsoft.com/en-us/powershell/module/az.compute/new-azvm)
  - [New-AzVMConfig](https://learn.microsoft.com/en-us/powershell/module/az.compute/new-azvmconfig)
  - [Set-AzVMOperatingSystem](https://learn.microsoft.com/en-us/powershell/module/az.compute/set-azvmoperatingsystem)
  - [Set-AzVMSourceImage](https://learn.microsoft.com/en-us/powershell/module/az.compute/set-azvmsourceimage)
  - [Add-AzVMNetworkInterface](https://learn.microsoft.com/en-us/powershell/module/az.compute/add-azvmnetworkinterface)

Azure PowerShell

Open Cloudshell

```azurepowershell
# Set the administrator and password for the VMs. ##
$cred = Get-Credential

## Place the virtual network into a variable. ##
$net = @{
    Name = 'myVNet'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
$vnet = Get-AzVirtualNetwork @net

## Place the load balancer into a variable. ##
$lb = @{
    Name = 'myLoadBalancer'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
$bepool = Get-AzLoadBalancer @lb  | Get-AzLoadBalancerBackendAddressPoolConfig

## Place the network security group into a variable. ##
$ns = @{
    Name = 'myNSG'
    ResourceGroupName = 'CreatePubLBQS-rg'
}
$nsg = Get-AzNetworkSecurityGroup @ns

## For loop with variable to create virtual machines for load balancer backend pool. ##
for ($i=1; $i -le 2; $i++){

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
        VMSize = 'Standard_B1s'  
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
    New-AzVM @vm
}
```

The deployments of the virtual machines and bastion host are submitted as PowerShell jobs. To view the status of the jobs, use [Get-Job](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-job):

Azure PowerShell

Open Cloudshell

```azurepowershell
Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
1      Long Running O… AzureLongRunni… Completed     True            localhost            New-AzBastion
2      Long Running O… AzureLongRunni… Completed     True            localhost            New-AzVM
3      Long Running O… AzureLongRunni… Completed     True            localhost            New-AzVM
```

Ensure the **State** of the VM creation is **Completed** before moving on to the next steps.

 Note

Azure provides a default outbound access IP for VMs that either aren't assigned a public IP address or are in the back-end pool of an internal basic Azure load balancer. The default outbound access IP mechanism provides an outbound IP address that isn't configurable.

The default outbound access IP is disabled when a public IP address is assigned to the VM, the VM is placed in the back-end pool of a standard load balancer, with or without outbound rules, or if an [Azure Virtual Network NAT gateway](https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-overview) resource is assigned to the subnet of the VM.

VMs that are created by virtual machine scale sets in flexible orchestration mode don't have default outbound access.

For more information about outbound connections in Azure, see [Default outbound access in Azure](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/default-outbound-access) and [Use source network address translation (SNAT) for outbound connections](https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-outbound-connections).



## Install IIS

Use [Set-AzVMExtension](https://learn.microsoft.com/en-us/powershell/module/az.compute/set-azvmextension) to install the Custom Script Extension.

The extension runs `PowerShell Add-WindowsFeature Web-Server` to install the IIS webserver and then updates the Default.htm page to show the hostname of the VM:

 Important

Ensure the virtual machine deployments have completed from the previous steps before proceeding. Use `Get-Job` to check the status of the virtual machine deployment jobs.

Azure PowerShell

Open Cloudshell

```azurepowershell
## For loop with variable to install custom script extension on virtual machines. ##
for ($i=1; $i -le 2; $i++)
{
$ext = @{
    Publisher = 'Microsoft.Compute'
    ExtensionType = 'CustomScriptExtension'
    ExtensionName = 'IIS'
    ResourceGroupName = 'CreatePubLBQS-rg'
    VMName = "myVM$i"
    Location = 'polandcentral'
    TypeHandlerVersion = '1.8'
    SettingString = '{"commandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
}
Set-AzVMExtension @ext
}
```

The extensions are deployed as PowerShell jobs. To view the status of the installation jobs, use [Get-Job](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-job):

Azure PowerShell

Open Cloudshell

```azurepowershell
Get-Job

Id     Name            PSJobTypeName   State         HasMoreData     Location             Command
--     ----            -------------   -----         -----------     --------             -------
8      Long Running O… AzureLongRunni… Running       True            localhost            Set-AzVMExtension
9      Long Running O… AzureLongRunni… Running       True            localhost            Set-AzVMExtension
```

Ensure the **State** of the jobs is **Completed** before moving on to the next steps.



## Test the load balancer

Use [Get-AzPublicIpAddress](https://learn.microsoft.com/en-us/powershell/module/az.network/get-azpublicipaddress) to get the public IP address of the load balancer:

Azure PowerShell

Open Cloudshell

```azurepowershell
$ip = @{
    ResourceGroupName = 'CreatePubLBQS-rg'
    Name = 'myPublicIP'
}  
Get-AzPublicIPAddress @ip | select IpAddress
```

Copy the public IP address, and then paste it into the address bar of your browser. The default page of IIS Web server is displayed on the browser.

![Screenshot of the load balancer test web page.](https://learn.microsoft.com/en-us/azure/load-balancer/media/quickstart-load-balancer-standard-public-portal/load-balancer-test.png)



## Clean up resources

When no longer needed, you can use the [Remove-AzResourceGroup](https://learn.microsoft.com/en-us/powershell/module/az.resources/remove-azresourcegroup) command to remove the resource group, load balancer, and the remaining resources.

Azure PowerShell

Open Cloudshell

```azurepowershell
Remove-AzResourceGroup -Name 'CreatePubLBQS-rg'
```



