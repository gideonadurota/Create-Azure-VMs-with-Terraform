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
        "10.0.1.0/32",
        "10.0.1.1/32",
        "10.0.1.2/32",
        "10.0.1.3/32",
        "10.0.1.4/32",
        "10.0.1.5/32",
        "10.0.1.6/32",
        "10.0.1.7/32",
        "10.0.1.8/32",
        "10.0.1.9/32"
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