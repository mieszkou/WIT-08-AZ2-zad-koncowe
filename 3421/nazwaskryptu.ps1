<#
------------------------------------------------
Blok zmiennych
------------------------------------------------
#>

# domyslne wartości:
$defaultRegion = "polandcentral" 
# pokazuj tylko europejskie lokalizacje na liscie regionow do wyboru $true|$false
$onlyEurope = $true
$defaultVmSize = "Standard_B1s"
$defaultVmSizesToShow = "Standard_B*"

$scriptFolder = Split-Path $MyInvocation.MyCommand.Path -Parent
$logFile = "$scriptFolder\log\log.txt"
$dataFile = "$scriptFolder\dane.txt"
$reportFile = "$scriptFolder\raport.txt"

$tagName = "student"

# szablony nazw dla zasobów
$nameTemplateRG = "RG_{0}"                  # $rgName = $nameTemplateRG -f $idNumber
$nameTemplateVM = "VM-{0}-{1}"              # $vmName = $nameTemplateVM -f $vmNameFromFile, $idNumber
$nameTemplateLB = "LB-{0}"                  # $lbName = $nameTemplateLB -f $idNumber
$nameTemplateSG = "SG-{0}"                  # $sgName = $nameTemplateSG -f $idNumber
$nameTemplateSA = "mystorageacctplwit{0}"   # $saName = $nameTemplateSA -f $idNumber

# odczyt domyslnego numeru indeksu z nazwy katalogu w którym znajduje się skrypt
$defaultIdNumber = Split-Path $MyInvocation.MyCommand.Path -Parent | Split-Path -Leaf  

<# 
------------------------------------------------
Blok funkcji
------------------------------------------------
#>

# Funkcja do zapisu komunikatu do pliku logu
function Write-Log { 
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy-MM-dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $logFile -value $LogMessage
}

# Funkcja wyświetla w konsoli informację dla użytkownika i zapisuje ją do pliku logu z sygnatura czasową
function Write-HostAndLog { 
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogString
    )

    Write-Log -LogString $LogString
    Write-Host $LogString
}

# Funkcja do obsługi wyjątków
# Wyświetla użytkownikowi opis problemu i zapisuje go w pliku logu
function Show-Except {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Collections.Generic.List[PSObject]] $obj
    )
    
    Write-Host
    Write-Host "Wystąpił błąd, linia: $($MyInvocation.ScriptLineNumber)"
    Write-Host "=================================================="
    Write-Host "$obj"
    Write-Host "=================================================="
    Write-Host
    
    Write-Log "$obj"
}

# Funkcja odpowiedzialna za wyświetlenie uzytkownikowi menu na podstawie tablicy
# uzywana w funkcji Get-User-Choice
function Show-Menu {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$MenuName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Options,
        
        [Parameter(Mandatory = $false)]
        [string]$defaultValue
    )
    if ($defaultValue) { $defaultValueIdx = $Options.IndexOf($defaultValue) } else {
        $defaultValueIdx = $null
    }
    
    # Clear-Host
    Write-Host "$MenuName ================"

    if ($Options.Count -eq 0) {
        Write-Host "Brak pozycji do wyświetlenia"
    }
    else {

        for ($i = 0; $i -lt $Options.Count; $i++) {
            Write-Host ("{0,3}. {1} {2}" -f ($i + 1), $Options[$i], $(if ($defaultValueIdx -eq $i) { " <-- [ENTER]" }) )
        }
    }
    Write-Host ("{0,3}. Wyjscie z programu lub przerwanie aktualnej operacji" -f "Q")
    Write-Host

    while ($true) {
        $choice = Read-Host "Wybor [$defaultValue]"
        try {
            if (($choice.Equals("q")) -Or ($choice.Equals("Q"))) {
                break subloop
            }
 
            if ($choice -eq "" -and $defaultValueIdx -ge 0) {
                $choice = $defaultValueIdx + 1
            } else {
                $choice = [int]$choice
            }
       
            if ($choice -ge 1 -and $choice -le $Options.Count) {
                return ($choice - 1)
            }
        
            Write-Host("Bledny wybor {0}. Wybierz wartość z zakresu 1-{1} lub 'q' aby przerwać" -f $choice, $Options.Count)
        }
        catch {
            Show-Except -obj $_
        }
    }
}

# Funkcja pytająca użytkownika o wybór wartości z tablicy
# z możliwością ustalenia wartości domyślnej, korzysta z funkcji `Show-Menu` do wyswietlenia opcji
function Get-User-Choice {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$MenuName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Options,

        [Parameter(Mandatory = $false)]
        [string]$defaultValue
    )
    return($Options[(Show-Menu -MenuName $MenuName -Options $Options -defaultValue $defaultValue)])
}

# Funkcja pobierająca tekst od użytkownika z możliwością ustawienia wartości domyślnej
function Get-User-Input {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrompt,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$defaultValue
    )
            
    if (!($val = Read-Host "$UserPrompt [$defaultValue]")) { $val = $defaultValue }
    return $val
}


<#
Funkcja sprawdzająca czy nazwa vm spełnia poniższy warunek
Windows computer name cannot be more than 15 characters long, be entirely numeric, 
or contain the following characters: ` ~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \ | ; : . ' " , < > / ?.
źródło funkcji: https://chat.openai.com
#>
function Test-VMName {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )

    $maxLength = 15
    $invalidCharacters = "`~!@#$%^&*()=+[]{}\|;:.',<>/?"
    
    $lengthValid = $ComputerName.Length -le $maxLength
    $numericValid = -not ($ComputerName -match "^\d+$")
    $charactersValid = -not ($ComputerName -match "[$invalidCharacters]")
    
    $valid = $lengthValid -and $numericValid -and $charactersValid
    
    return $valid
}

<#
------------------------------------------------
Blok skryptu
------------------------------------------------
#>


# sprawdzenie czy pliki dane i log istnieją
# w oparciu o https://adamtheautomator.com/powershell-check-if-file-exists/

if (-not(Test-Path -Path $logFile)) {
    try {
        $null = New-Item -ItemType File -Path $logFile -Force -ErrorAction Stop
        Write-Log "The file [$logFile] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}

if (-not(Test-Path -Path $dataFile -PathType Leaf)) {
    try {
        "zeus,zeusadmin,Oqu4$%ueD5eisaah!" | Out-File $dataFile
        "venus,venusadmin,qu#ei3iG_aequ2x" | Out-File $dataFile -Append
        Write-Log "The file [$dataFile] has been created."
   }
    catch {
        throw $_.Exception.Message
    }
}

Write-Log "-------- POCZATEK PRACY"


# Sprawdzenie wymagań
# wymagane moduly i sprawdzenie czy sa dostepne w systemie
$reqModules = @(
    "Az.Accounts",
    "Az.Compute",
    "Az.Storage",
    "Az.Resources",
    "Az.Network",
    "AzureAD"
)

$errorFlag = $false

foreach ($mod in $reqModules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "!! Moduł $mod nie jest zainstalowany."
        Write-Host "Instalacja poleceniem (jako administrator): "
        Write-Host "Install-Module -Name $mod"
        Write-Host "Lub instalacja tylko dla uzytkownika: "
        Write-Host "Install-Module -Name $mod -Scope CurrentUser"
        Write-Host 
        $errorFlag = $true
    }
}

if ($errorFlag) {
    Exit
}

Import-Module Az.Accounts
Import-Module Az.Compute
Import-Module Az.Storage
Import-Module Az.Resources
Import-Module Az.Network
Import-Module AzureAD

# Logowanie do AZ i AD
try {
    Write-HostAndLog "Logowanie do konta AZ"
    Connect-AzAccount | Format-Table
    $subscriptions = Get-AzContext | Select-Object -ExpandProperty Subscription
    $subscription = Get-User-Choice -MenuName "Subscriptions" -Options $subscriptions
    Set-AzContext -SubscriptionId $subscription
    Write-HostAndLog "Logowanie do konta AD"
    $context=Get-AzContext
    Connect-AzureAD -TenantId $context.Tenant.Id -AccountId $context.Account.Id | Format-Table
    # logowanie automatyczne
    # $context=Get-AzContext
    # Connect-AzureAD -TenantId $context.Tenant.Id -AccountId $context.Account.Id | Format-Table

}
catch { 
    Show-Except -obj $_
    exit
}


try {

    # pobieramy od uzytkownika nr indeksu z propozycja domyslnej wartosci odczytanej
    # z nazwy katalogu w którym jest skrypt
    $idNumber = Get-User-Input -UserPrompt "Podaj nr indeksu" -defaultValue $defaultIdNumber
    Write-Log("Podany numer indeksu: $idNumber")

    # wybór regionu
    Write-HostAndLog("Odczytuje dostepne lokalizacje")
    if ($onlyEurope) { 
        $locations = Get-AzLocation | Where-Object GeographyGroup -eq "Europe" | Select-Object -ExpandProperty Location 
    } else {  
        $locations = Get-AzLocation | Select-Object -ExpandProperty Location 
    }
    $location = Get-User-Choice -MenuName "Wybierz lokalizacje" -Options $locations -defaultValue $defaultRegion
    Write-Log("Wybrany region: $location")
    
    # ustawiamy nazwy zgodnie z szablonami
    $groupName = $nameTemplateRG -f $idNumber
    $vmName = $nameTemplateVM -f $vmNameFromFile, $idNumber
    $storageAccountName = $nameTemplateSA -f $idNumber
    
    # tu ustawiam "na sztywno"
    # $vmSize = $defaultVmSize
    # lub wybor przez uzytkownika z dostepnych wg filtru $defaultVmSizesToShow
    $vmSize = (Get-User-Choice -defaultValue $defaultVmSize -MenuName "Wybierz rozmiar VM" -Options $(Get-AzVMSize -Location $location  | Where-Object Name -Like $defaultVmSizesToShow | Select-Object -ExpandProperty Name))

    $tagValue = $idNumber

    # Odczyt nazw maszyn wirtualnych z pliku dane.txt
    
    Write-HostAndLog "Odczyt danych VM z pliku $dataFile"
    $vmCredentials = Import-Csv -Path $dataFile -Header "name", "login", "password"

    # Przetwarzanie danych i tworzenie tablicy z nazwami VM, loginami i hasłami
    $vms = foreach ($credential in $vmCredentials) {
        $vmName = $nameTemplateVM -f $credential.name, $idNumber

        if (Test-VMName($vmName)) {
            Write-HostAndLog "VM: $vmName"
   
            [PSCustomObject]@{
                Name     = $vmName
                Login    = $credential.Login
                Password = $credential.Password
            }
        }
        else {
            Throw("Nazwa VM $vmName nie jest poprawna")
        }
    }
}

catch { 
    Show-Except -obj $_
    Exit
}
    

# Tworzenie grupy zasobów
try {
    Write-HostAndLog "Tworzenie grupy zasobów: $groupName"
    if(New-AzResourceGroup -Name $groupName -Location $location) {
        Write-HostAndLog "Grupa zasobow $groupName utworzona."
    } else {
        Write-HostAndLog "Błąd podczas tworzenia grupy zasobow $groupName."
    } 
} catch { 
    Show-Except -obj $_
    Exit
}
    

# Tworzenie obiektów
try {

    
    # tworzenie storage account
    Write-HostAndLog "Create storage account $storageAccountName"
    if(New-AzStorageAccount -ResourceGroupName $groupName -Name $storageAccountName -Location $location -SkuName Standard_LRS -Kind StorageV2 -AllowBlobPublicAccess $true) {
        Write-HostAndLog "Create storage account $storageAccountName - OK"
    } else {
        Throw("Create storage account $storageAccountName - ERROR")
    }

    # Tworzenie usługi LB do której podłączone zostana VM-ki w oparciu o
    # https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-powershell
    # z tej strony też pochodzą komentarze w j. angielskim 
    # nazwy obiektów są utworzone na podstawie nazwy LB $loadBalancerName 
    # dodałem warunki if do logowania zdarzen w pliku log-u, poprawiłem odwołania do innych obiektów w skrypcie
    
    $loadBalancerName = $nameTemplateLB -f $idNumber
    Write-HostAndLog "Create load balancer $loadBalancerName"
    
    # Create a public IP address
    # Use New-AzPublicIpAddress to create a public IP address.
        
    $publicip = @{
        Name = $($loadBalancerName + '-myPublicIP')
        ResourceGroupName = $groupName
        Location = $location
        Sku = 'Standard'
        AllocationMethod = 'static'
        Zone = 1,2,3
    }
    if(New-AzPublicIpAddress @publicip -WarningAction silentlyContinue) {
        Write-HostAndLog "Create a public IP address - OK"
    } else {
        Throw("Create a public IP address - ERROR")
    }

    # Create a load balancer
    
    ## Place public IP created in previous steps into variable. ##
    $pip = @{
        Name = $($loadBalancerName + '-myPublicIP')
        ResourceGroupName = $groupName
    }
    $publicIp = Get-AzPublicIpAddress @pip -WarningAction silentlyContinue

    ## Create load balancer frontend configuration and place in variable. ##
    $fip = @{
        Name = $($loadBalancerName + '-myFrontEnd')
        PublicIpAddress = $publicIp
    }
    if($feip = New-AzLoadBalancerFrontendIpConfig @fip) {
        Write-HostAndLog "Create load balancer frontend configuration - OK"
    } else {
        Throw("Create load balancer frontend configuration - ERROR")
    }

    ## Create backend address pool configuration and place in variable. ##
    if($bepool = New-AzLoadBalancerBackendAddressPoolConfig -Name $($loadBalancerName + '-myBackEndPool')){
        Write-HostAndLog "Create backend address pool configuration - OK"
    } else {
        Throw("Create backend address pool configuration - ERROR")
    }

    ## Create the health probe and place in variable. ##
    $probe = @{
        Name = $($loadBalancerName + '-myHealthProbe')
        Protocol = 'tcp'
        Port = '80'
        IntervalInSeconds = '360'
        ProbeCount = '5'
    }
    if($healthprobe = New-AzLoadBalancerProbeConfig @probe) {
        Write-HostAndLog "Create the health probe - OK"
    } else {
        Throw("Create the health probe - ERROR")
    }

    ## Create the load balancer rule and place in variable. ##
    $lbrule = @{
        Name = $($loadBalancerName + '-myHTTPRule')
        Protocol = 'tcp'
        FrontendPort = '80'
        BackendPort = '80'
        IdleTimeoutInMinutes = '15'
        FrontendIpConfiguration = $feip
        BackendAddressPool = $bePool
    }

    $lbrule443 = @{
        Name = $($loadBalancerName + '-myHTTPSRule')
        Protocol = 'tcp'
        FrontendPort = '443'
        BackendPort = '443'
        IdleTimeoutInMinutes = '15'
        FrontendIpConfiguration = $feip
        BackendAddressPool = $bePool
    }

    if($rule1 = New-AzLoadBalancerRuleConfig @lbrule -EnableTcpReset -DisableOutboundSNAT) {
        Write-HostAndLog "Create the load balancer rule - OK"
    } else {
        Throw("Create the load balancer rule - ERROR")
    }

    if($rule2 = New-AzLoadBalancerRuleConfig @lbrule443 -EnableTcpReset -DisableOutboundSNAT) {
        Write-HostAndLog "Create the load balancer rule - OK"
    } else {
        Throw("Create the load balancer rule - ERROR")
    }



    ## Create the load balancer resource. ##
    $loadbalancer = @{
        ResourceGroupName = $groupName
        Name = $loadBalancerName
        Location = $location
        Sku = 'Standard'
        FrontendIpConfiguration = $feip
        BackendAddressPool = $bePool
        LoadBalancingRule = ($rule2, $rule1)
        Probe = $healthprobe
    }
    if(New-AzLoadBalancer @loadbalancer) {
        Write-HostAndLog "Create the load balancer resource - OK"
    } else {
        Throw("Create the load balancer resource - ERROR")
    }

    ## Create public IP address for NAT gateway ##
    $ip = @{
        Name = $($loadBalancerName + '-myNATgatewayIP')
        ResourceGroupName = $groupName
        Location = $location
        Sku = 'Standard'
        AllocationMethod = 'Static'
    }
    if($publicIP = New-AzPublicIpAddress @ip) {
        Write-HostAndLog "Create public IP address for NAT gateway - OK"
    } else {
        Throw("Create public IP address for NAT gateway - ERROR")
    }

    ## Create NAT gateway resource ##
    $nat = @{
        ResourceGroupName = $groupName
        Name = $($loadBalancerName + '-myNATgateway')
        IdleTimeoutInMinutes = '10'
        Sku = 'Standard'
        Location = $location
        PublicIpAddress = $publicIP
    }
    if($natGateway = New-AzNatGateway @nat) {
        Write-HostAndLog "Create NAT gateway resource - OK"
    } else {
        Throw("Create NAT gateway resource - ERROR")
    }

    ## Create backend subnet config ##
    $subnet = @{
        Name = $($loadBalancerName + '-myBackendSubnet')
        AddressPrefix = '10.1.0.0/24'
        NatGateway = $natGateway
    }
    if($subnetConfig = New-AzVirtualNetworkSubnetConfig @subnet) {
        Write-HostAndLog "Create backend subnet config - OK"
    } else {
        Throw("Create backend subnet config - ERROR")
    }

    ## Create Azure Bastion subnet. ##
    $bastsubnet = @{
        Name = 'AzureBastionSubnet'
        AddressPrefix = '10.1.1.0/24'
    }
    if($bastsubnetConfig = New-AzVirtualNetworkSubnetConfig @bastsubnet) {
        Write-HostAndLog "Create Azure Bastion subnet - OK"
    } else {
        Throw("Create Azure Bastion subnet - ERROR")
    }

    ## Create the virtual network ##
    $net = @{
        Name = $($loadBalancerName + '-myVNet')
        ResourceGroupName = $groupName
        Location = $location
        AddressPrefix = '10.1.0.0/16'
        Subnet = $subnetConfig,$bastsubnetConfig
    }
    if($vnet = New-AzVirtualNetwork @net) {
        Write-HostAndLog "Create the virtual network - OK"
    } else {
        Throw("Create the virtual network - ERROR")
    }

    ## Create public IP address for bastion host. ##
    $ip = @{
        Name = $($loadBalancerName + '-myBastionIP')
        ResourceGroupName = $groupName
        Location = $location
        Sku = 'Standard'
        AllocationMethod = 'Static'
    }
    if($publicip = New-AzPublicIpAddress @ip) {
        Write-HostAndLog "Create public IP address for bastion host - OK"
    } else {
        Throw("Create public IP address for bastion host - ERROR")
    }

    # ## Create bastion host ##
    # Write-HostAndLog "Create bastion host (to trwa dlugo ..... )"
    # $bastion = @{
    #     ResourceGroupName = $groupName
    #     Name = $($loadBalancerName + '-myBastion')
    #     PublicIpAddress = $publicip
    #     VirtualNetwork = $vnet
    # }
    # if(New-AzBastion @bastion) {
    #     Write-HostAndLog "Create bastion host - OK"
    # } else {
    #     Throw("Create bastion host - ERROR")
    # }

    ## Create rule for network security group and place in variable. ##
    $nsgrule = @{
        Name = $($loadBalancerName + '-myNSGRuleHTTP')
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
    if($rule1 = New-AzNetworkSecurityRuleConfig @nsgrule) {
        Write-HostAndLog "Create rule for network security group - OK"
    } else {
        Throw("Create rule for network security group - ERROR")
    }

    $nsgrule = @{
        Name = $($loadBalancerName + '-myNSGRuleHTTPS')
        Description = 'Allow HTTPS'
        Protocol = '*'
        SourcePortRange = '*'
        DestinationPortRange = '443'
        SourceAddressPrefix = 'Internet'
        DestinationAddressPrefix = '*'
        Access = 'Allow'
        Priority = '2001'
        Direction = 'Inbound'
    }
    if($rule2 = New-AzNetworkSecurityRuleConfig @nsgrule) {
        Write-HostAndLog "Create rule for network security group 2 - OK"
    } else {
        Throw("Create rule for network security group 2 - ERROR")
    }

    ## Create network security group ##
    $nsg = @{
        Name = $($loadBalancerName + '-myNSG')
        ResourceGroupName = $groupName
        Location = $location
        SecurityRules = ($rule1, $rule2)
    }
    if(New-AzNetworkSecurityGroup @nsg) {
        Write-HostAndLog "Create network security group - OK"
    } else {
        Throw("Create network security group - ERROR")
    }

    # odczyt wartosci do tworzenia vm
    $net = @{
        Name = $($loadBalancerName + '-myVNet')
        ResourceGroupName = $groupName
    }
    $vnet = Get-AzVirtualNetwork @net
    
    $lb = @{
        Name = $loadBalancerName
        ResourceGroupName = $groupName
    }
    $bepool = Get-AzLoadBalancer @lb  | Get-AzLoadBalancerBackendAddressPoolConfig
    
    ## Place the network security group into a variable. ##
    $ns = @{
        Name = $($loadBalancerName + '-myNSG')
        ResourceGroupName = $groupName
    }
    $nsg = Get-AzNetworkSecurityGroup @ns
    

    # Tworzenie maszyn wirtualnych    
    Write-HostAndLog "Tworzenie maszyn wirtualnych"
    foreach ($vm in $vms) {

        ## Command to create network interface for VMs ##
        $nic = @{
            Name = $($vm.Name)
            ResourceGroupName = $groupName
            Location = $location
            Subnet = $vnet.Subnets[0]
            NetworkSecurityGroup = $nsg
            LoadBalancerBackendAddressPool = $bepool
        }
        if($nicVM = New-AzNetworkInterface @nic) {
            Write-HostAndLog "Create network interface for VM $($vm.Name) - OK"
        } else {
            Throw("Create network interface for VM $($vm.Name) - ERROR")
        }

        $vmsz = @{
            VMName = $($vm.Name)
            VMSize = $vmSize
        }

        $login = $vm.Login
        $password = $vm.Password
        $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
        $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $login, $securePassword

        $vmos = @{
            ComputerName = $($vm.Name)
            Credential = $credential
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
            | Set-AzVMBootDiagnostic -disable `
            | Add-AzVMNetworkInterface -Id $nicVM.Id
    
        ## Create the virtual machine for VMs ##
        $vmSet = @{
            ResourceGroupName = $groupName
            Location = $location
            VM = $vmConfig
            Zone = "1"
        }
        
        Write-HostAndLog "Tworzenie VM: $($vm.Name)"
        if (New-AzVM @vmSet) {
            Write-HostAndLog "$($vm.Name) utworzona."
        } else {
            Write-HostAndLog "Błąd podczas tworzenia $($vm.Name)"
        }
    }


    # utworzenie grupy zabezpieczeń
    Write-HostAndLog "Create security group"
   
    $securityGroupName = $nameTemplateSG -f $idNumber
    $securityGroup = New-AzureADGroup -DisplayName $securityGroupName -SecurityEnabled $true -Description "Security group for $groupName"  -MailEnabled $false -MailNickName "NotSet"
    
    $resourceGroup = Get-AzResourceGroup -Name $groupName
    New-AzRoleAssignment -ObjectId $securityGroup.ObjectId -RoleDefinitionName "Contributor" -ResourceGroupName $resourceGroup.ResourceGroupName

    # Dodajmy tag do wszystkich obiektow RG
    Write-HostAndLog "Add tag"
    $tags = @{$tagName=$tagValue}
    $resource = Get-AzResourceGroup -Name $groupName
    New-AzTag -Tag $tags -ResourceId $resource.ResourceId 
    
    $resources = Get-AzResource -ResourceGroupName $groupName
    $resources | ForEach-Object { 
        Write-Host "Adding tag to $($_.Name)"
        New-AzTag -Tag $tags -ResourceId $_.ResourceId | Out-Null
    }


    Write-HostAndLog "Przygotowanie raportu w pliku $reportFile"
    $resources = Get-AzResource -ResourceGroupName $groupName

    $raport = foreach ($resource in $resources) {
        $tags = $resource.Tags | ConvertTo-Json

        [pscustomobject]@{
            Nazwa = $resource.Name
            Typ = $resource.ResourceType
            ID = $resource.ResourceId
            Tagi = $tags
        }
    }

    $raport | Format-List | Out-File $reportFile

    $dane = Get-Content $dataFile -Raw
    $dane | Add-Content $reportFile

    # Install IIS on VMs 
    # https://learn.microsoft.com/en-us/azure/load-balancer/quickstart-load-balancer-standard-public-powershell
    Write-HostAndLog "Install IIS"
    foreach ($vm in $vms) {
        Write-HostAndLog "Install IIS on $($vm.Name)"
        $ext = @{
            Publisher = 'Microsoft.Compute'
            ExtensionType = 'CustomScriptExtension'
            ExtensionName = 'IIS'
            ResourceGroupName = $groupName
            VMName = $($vm.Name)
            Location = $location
            TypeHandlerVersion = '1.8'
            SettingString = '{"commandToExecute":"powershell Install-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"}'
        }
        if(Set-AzVMExtension @ext) {
            Write-HostAndLog "Install IIS on $($vm.Name) - OK"
        } else {
            Throw("Install IIS on $($vm.Name) - ERROR")
        }
    }

    $ipToShow = Get-AzPublicIPAddress -Name $($loadBalancerName + '-myPublicIP') | Select-Object IpAddress

    Write-Host "https://portal.azure.com/ <-- portal Azure"
    Write-Host "http://$($ipToShow.IpAddress) <-- test Load Balancera"
    Read-Host -Prompt "STOP - Czas na sprawdzenie. Po nacisnieciu [ENTER] $groupName zostanie usunieta razem ze wszsytkimi obiektami wew."
    Write-HostAndLog "-------- KONIEC"

} catch { 
    Show-Except -obj $_
    # w przypadku bledu nie wychodze z programu tylko w kolejnym kroku usuwam RG
}

try {
    # Usuwanie utworzonych obiektów
    Write-HostAndLog "Usuwanie $groupName raze z objektami zaleznymi (to trwa dlugo ..... )"

    if(Remove-AzResourceGroup -Name $groupName -Force) {
    Write-HostAndLog "$groupName usunieta."
    } else {
    Write-HostAndLog "Błąd podczas usuwania $groupName."
    }
    if($securityGroup.ObjectId) {
        if(remove-AzureADGroup -ObjectId $securityGroup.ObjectId) {

        }
    }
    Read-Host -Prompt "[ENTER] aby zakonczyc"
} catch { 
    Show-Except -obj $_
    Exit
}


