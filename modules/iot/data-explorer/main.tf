resource "azurerm_kusto_cluster" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    name     = var.sku_name
    capacity = var.sku_capacity
  }

  tags = var.tags
}
