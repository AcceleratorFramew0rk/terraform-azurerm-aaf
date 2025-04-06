

// Container Registry
resource "azurerm_container_registry" "this" {
  name                     = "${replace(var.base_name,"-","")}cr"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  sku                      = "Premium"
  admin_enabled            = false

  network_rule_set {
    default_action         = "Deny"
  }
}

resource "azurerm_private_dns_zone" "acr_dns_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name           = var.resource_group_name
}

resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "${azurerm_container_registry.this.name}-pep"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  subnet_id      = var.subnet_id # try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id

  private_service_connection {
    name                           = "acrConnection"
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  
  private_dns_zone_group {
    name = "acr-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr_dns_zone.id]
  }
}

// Output to get the ACR login server
output "login_server" {
  description = "The login server of the Azure Container Registry"
  value       = azurerm_container_registry.this.login_server
}
