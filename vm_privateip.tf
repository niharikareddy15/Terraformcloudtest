resource "azurerm_resource_group" "myterraformgroup1" {
    name     = "myResourceGroup1"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}


resource "azurerm_virtual_network" "myterraformnetwork1" {
    name                = "myVnet1"
    address_space       = ["10.1.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup1.name

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_subnet" "myterraformsubnet1" {
    name                 = "mySubnet1"
    resource_group_name  = azurerm_resource_group.myterraformgroup1.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork1.name
    address_prefixes       = ["10.0.2.0/24"]
}


resource "azurerm_network_security_group" "myterraformnsg1" {
    name                = "myNetworkSecurityGroup1"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup1.name
    
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface" "myterraformnic1" {
    name                        = "myNIC1"
    location                    = "eastus"
    resource_group_name         = azurerm_resource_group.myterraformgroup1.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet1.id
        private_ip_address_allocation = "Static"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example1" {
    network_interface_id      = azurerm_network_interface.myterraformnic1.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg1.id
}

resource "azurerm_virtual_machine" "main1" {
  name                  = "myVM1"
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.myterraformgroup1.name
  network_interface_ids = [azurerm_network_interface.myterraformnic1.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
	disk_size_gb  = "100"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "Terraform Demo"
  }
}
