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

# Kusto Database
resource "azurerm_kusto_database" "adx_database" {
  name                = "${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  cluster_name        = azurerm_kusto_cluster.this.name
  soft_delete_period  = var.soft_delete_period
  hot_cache_period    = var.hot_cache_period
}