resource "azurerm_resource_group" "myterraformgroup2" {
    name     = "KuberneteesTask"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_virtual_network" "myterraformnetwork2" {
    name                = "myVnetAKS"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup2.name

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "myterraformsubnet2" {
    name                 = "mySubnet01"
    resource_group_name  = azurerm_resource_group.myterraformgroup2.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork2.name
    address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "myterraformsubnet3" {
    name                 = "mySubnet02"
    resource_group_name  = azurerm_resource_group.myterraformgroup2.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork2.name
    address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "myterraformsubnet4" {
    name                 = "mySubnet01"
    resource_group_name  = azurerm_resource_group.myterraformgroup2.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork2.name
    address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_kubernetes_cluster" "aks1" {
  name                = "myAKS15"
  location            = azurerm_resource_group.myterraformgroup2.location
  resource_group_name = azurerm_resource_group.myterraformgroup2.name
  dns_prefix          = "exampleAKS15"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate1" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
}

output "kube_config1" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
}

resource "azurerm_public_ip" "pip" {
  name                         = "my-pip-12345"
  location                     = "${azurerm_resource_group.myterraformgroup2.location}"
  resource_group_name          = "${azurerm_resource_group.myterraformgroup2.name}"
  allocation_method            = "Dynamic"
}


# Create an application gateway
resource "azurerm_application_gateway" "gateway1" {
  name                = "my-application-gateway-12345"
  resource_group_name = azurerm_resource_group.myterraformgroup2.name
  location            = azurerm_resource_group.myterraformgroup2.location

  sku {
    name           = "Standard_Small"
    tier           = "Standard"
    capacity       = 2
  }
  
  gateway_ip_configuration {
      name         = "my-gateway-ip-configuration"
      subnet_id    = "${azurerm_virtual_network.myterraformnetwork2.id}/subnets/${azurerm_subnet.myterraformsubnet2.name}"
  }

  frontend_port {
      name         = "${azurerm_virtual_network.myterraformnetwork2.name}-feport"
      port         = 80
  }

  frontend_ip_configuration {
      name         = "${azurerm_virtual_network.myterraformnetwork2.name}-feip"
      public_ip_address_id = "${azurerm_public_ip.pip.id}"
  }

  backend_address_pool {
      name = "${azurerm_virtual_network.myterraformnetwork2.name}-beap"
  }

  backend_http_settings {
      name                  = "${azurerm_virtual_network.myterraformnetwork2.name}-be-htst"
      cookie_based_affinity = "Disabled"
      port                  = 80
      protocol              = "Http"
     request_timeout        = 1
  }

  http_listener {
        name                                  = "${azurerm_virtual_network.myterraformnetwork2.name}-httplstn"
        frontend_ip_configuration_name        = "${azurerm_virtual_network.myterraformnetwork2.name}-feip"
        frontend_port_name                    = "${azurerm_virtual_network.myterraformnetwork2.name}-feport"
        protocol                              = "Http"
  }

  request_routing_rule {
          name                       = "${azurerm_virtual_network.myterraformnetwork2.name}-rqrt"
          rule_type                  = "Basic"
          http_listener_name         = "${azurerm_virtual_network.myterraformnetwork2.name}-httplstn"
          backend_address_pool_name  = "${azurerm_virtual_network.myterraformnetwork2.name}-beap"
          backend_http_settings_name = "${azurerm_virtual_network.myterraformnetwork2.name}-be-htst"
  }
}


