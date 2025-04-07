

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
  tags = var.tags
}

resource "azurerm_private_dns_zone" "acr_dns_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name           = var.resource_group_name
  tags = var.tags
}

resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "${azurerm_container_registry.this.name}-pep"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  subnet_id      = var.private_endpoint_subnet_id 

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


resource "azurerm_monitor_diagnostic_setting" "acr_diagnostics_settings" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? "${each.value.name}-acr" : "diag-${var.name}-acr" 
  target_resource_id             = azurerm_container_registry.this.id
  log_analytics_destination_type = "Dedicated" # hard setting this value to null to maintain compliance with the spec until this service supports either log analytics destination type
  log_analytics_workspace_id     = each.value.workspace_resource_id 

  dynamic "enabled_log" {
    for_each = each.value.log_categories

    content {
      category = enabled_log.value
    }
  }
  dynamic "enabled_log" {
    for_each = each.value.log_groups

    content {
      category_group = enabled_log.value
    }
  }
  dynamic "metric" {
    for_each = each.value.metric_categories

    content {
      category = metric.value
    }
  }
}
