terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.sub-id
}

#Create resource group
resource "azurerm_resource_group" "resourceGroup" {
    name = var.resourceGroup
    location = var.location
}

#Create virtual network
resource "azurerm_virtual_network" "V-Net" {
    name                = var.vnet
    address_space       = var.vnet-address-space
    location            = azurerm_resource_group.resourceGroup.location
    resource_group_name = azurerm_resource_group.resourceGroup.name
}

#Create subnets
resource "azurerm_subnet" "AppDiscovery-subnet" {
    count                = var.number-of-vms
    name                 = "subnet-${count.index}"
    resource_group_name  = azurerm_resource_group.resourceGroup.name
    virtual_network_name = azurerm_virtual_network.V-Net.name
    address_prefixes     = [element(var.subnet-address-space, count.index)]
}

#Create network interface
resource "azurerm_network_interface" "vmnic" {
  # for_each                      = azurerm_subnet.AppDiscovery-subnet
  # name                 = "vm-${length(var.subnet-address-space).index}"
  count               = var.number-of-vms
  name                = "vm-${count.index}-nic"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  ip_configuration {
    #for_each                      = azurerm_subnet.AppDiscovery-subnet
    #name                          = "testconfiguration-${count.index}"
    name                          = "testconfiguration-${count.index}"
    subnet_id                     = azurerm_subnet.AppDiscovery-subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip-address[count.index].id
  }
}

#Create public IP
resource "azurerm_public_ip" "public-ip-address" {
  count               = var.number-of-vms
  name                = "pulic-ip-${count.index}"
  resource_group_name = azurerm_resource_group.resourceGroup.name
  location            = azurerm_resource_group.resourceGroup.location
  allocation_method   = "Static"

}

#create NSGs
resource "azurerm_network_security_group" "nsg" {
  count               = var.number-of-vms
  name                = "acceptanceTestSecurityGroup-${count.index}"
  location            = azurerm_resource_group.resourceGroup.location
  resource_group_name = azurerm_resource_group.resourceGroup.name

  security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 340
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#Create the association between NSG and NIC
resource "azurerm_network_interface_security_group_association" "NSG-NIC-Association" {
  count                = var.number-of-vms
  network_interface_id      = azurerm_network_interface.vmnic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg[count.index].id
}

#create VMs
resource "azurerm_windows_virtual_machine" "virtual-machine" {
   count               = var.number-of-vms 
   name                = "AppDiscovery-vm-${count.index}"
   resource_group_name = azurerm_resource_group.resourceGroup.name
   location            = azurerm_resource_group.resourceGroup.location
   size                = "Standard_B2ms"
   network_interface_ids = [
     azurerm_network_interface.vmnic.*.id[count.index],
   ]
    computer_name       = var.computer-name
    admin_username      = var.admin-username
    admin_password      = var.admin-password
   
  os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
     publisher = "MicrosoftWindowsServer"
     offer     = "WindowsServer"
     sku       = "2016-Datacenter"
     version   = "latest"
   }
}

#Create storage account to keep the custom script file
resource "azurerm_storage_account" "appdisc-storage" {
    name                     = var.storage-name
    resource_group_name      = azurerm_resource_group.resourceGroup.name
    location                 = azurerm_resource_group.resourceGroup.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}