# main.tf
provider "azurerm" {
  features {}
}

resource "azurerm_iothub" "iot_hub" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku {
    name     = var.sku
    capacity = var.capacity
  }
  public_network_access_enabled = var.public_network_access_enabled  # Disables public access
  
  tags = var.tags
}
