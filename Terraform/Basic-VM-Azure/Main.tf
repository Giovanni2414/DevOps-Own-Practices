# First configure the microsoft azure provider
provider "azurerm" {
  features { }
}

# Create a resource group for our machine
resource "azurerm_resource_group" "first-practice-vm-rg" {
  location = var.resource_group_location
  name = "first-practice-vm-rg"
}

# Create the network
resource "azurerm_virtual_network" "first-vm-network" {
  name                = "first-vm-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.first-practice-vm-rg.name
}

# Create the subnet into the previous network
resource "azurerm_subnet" "first-vm-network-subnet" {
  name                 = "first-vm-network-subnet"
  resource_group_name  = azurerm_resource_group.first-practice-vm-rg.name
  virtual_network_name = azurerm_virtual_network.first-vm-network.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a public IP to our machine
resource "azurerm_public_ip" "first-vm-with-terraform-public-ip" {
    name                = "PublicIp_first_vm"
    resource_group_name = azurerm_resource_group.first-practice-vm-rg.name
    location            = var.resource_group_location
    allocation_method   = "Dynamic"
}

# Create a network interface
resource "azurerm_network_interface" "first-vm-network-interface" {
  name                = "first-vm-network-interface"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.first-practice-vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.first-vm-network-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.first-vm-with-terraform-public-ip.ip_address 
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "first-vm-with-terraform-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Now let's create a Virtual Machine
resource "azurerm_linux_virtual_machine" "first-vm-with-terraform" {
  name = "first-vm-with-terraform"
  location = var.resource_group_location
  resource_group_name = azurerm_resource_group.first-practice-vm-rg.name
  size = "Standard_B1s"
  admin_username = "admin_username"
  network_interface_ids = [
    azurerm_network_interface.first-vm-network-interface.id,
  ]

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username = "admin_username"
    public_key = tls_private_key.first-vm-with-terraform-ssh-key.public_key_openssh
  }
}

# Data source to get the information about the previous created machine
data "azurerm_virtual_machine" "first-vm-with-terraform-data" {
  name = azurerm_linux_virtual_machine.first-vm-with-terraform.name
  resource_group_name = azurerm_resource_group.first-practice-vm-rg.name
}