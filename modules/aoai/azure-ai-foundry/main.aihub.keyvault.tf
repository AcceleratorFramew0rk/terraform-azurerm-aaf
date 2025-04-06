resource "azurerm_key_vault" "this" {
  name                = "${replace(var.base_name,"-","")}kv" # "${module.naming.key_vault.name_unique}ai${random_string.this.result}"  # "thiskv"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                 = "standard"
  purge_protection_enabled = true
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
