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