variable "sub-id" {
    type = string  
}

variable "resourceGroup" {
    default = "AppDiscover-rg"
    type = string
}

variable "location" {
    default = "West Europe"
    type = string
}

variable "vnet" {
    default = "AppDisc-vnet"  
    type = string
}

variable "vnet-address-space" {
    default = ["10.0.0.0/16"]
}

variable "number-of-vms" {
  type = string
}

variable "subnet-address-space" {
    type = list
    default = [
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24",
        "10.0.4.0/24",
        "10.0.5.0/24",
        "10.0.6.0/24",
        "10.0.7.0/24",
        "10.0.8.0/24",
        "10.0.9.0/24",
        "10.0.10.0/24"
    ]
}

variable "admin-username" {
  type = string
}

variable "admin-password" {
  type = string
}

variable "computer-name" {
  default = "hostname"
}

variable "storage-name" {
  default = "appdisc3254"
}

variable "storage-container" {
  default = "script"
}