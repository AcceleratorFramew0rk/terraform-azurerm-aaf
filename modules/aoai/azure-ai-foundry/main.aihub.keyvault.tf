resource "azurerm_key_vault" "this" {
  name                = "${replace(var.base_name,"-","")}kv" # "${module.naming.key_vault.name_unique}ai${random_string.this.result}"  # "thiskv"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                 = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled = true
  public_network_access_enabled = false
  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "Delete",
    "Purge",
    "GetRotationPolicy",
  ]
}


resource "azurerm_private_dns_zone" "kv_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name           = var.resource_group_name
  tags = var.tags
}

resource "azurerm_private_endpoint" "kv_private_endpoint" {
  name                = "${azurerm_key_vault.this.name}-pep"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  subnet_id      = var.private_endpoint_subnet_id # try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id

  private_service_connection {
    name                           = "kvConnection"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  
  private_dns_zone_group {
    name = "kv-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns_zone.id]
  }
}


resource "azurerm_monitor_diagnostic_setting" "kv_diagnostics_settings" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? "${each.value.name}-kv" : "diag-${var.name}-kv" 
  target_resource_id             = azurerm_key_vault.this.id
  log_analytics_destination_type = "Dedicated" #hard setting this value to null to maintain compliance with the spec until this service supports either log analytics destination type
  log_analytics_workspace_id     = each.value.workspace_resource_id # var.log_analytics_workspace_id

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
