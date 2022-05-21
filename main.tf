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