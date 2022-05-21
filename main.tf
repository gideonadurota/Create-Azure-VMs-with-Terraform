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