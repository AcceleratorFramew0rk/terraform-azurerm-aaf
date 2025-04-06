resource "azurerm_ai_foundry" "this" {
  name                = var.name # "ai-hub-${random_string.this.result}" 
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  storage_account_id  = azurerm_storage_account.this.id
  key_vault_id        = azurerm_key_vault.this.id
  container_registry_id = azurerm_container_registry.this.id
  application_insights_id = azurerm_application_insights.this.id
  friendly_name             = "mlw-${var.base_name}"
  description              = "machine learning workspace for ${var.base_name}"

  public_network_access = "Enabled" # "Disabled" - once disabled, cannot be view from the portal
  managed_network {
    isolation_mode = "AllowOnlyApprovedOutbound"
    # outbound_rules = {
    #   # search = {
    #   #   type = "PrivateEndpoint"
    #   #   destination = {
    #   #     service_resource_id = var.search_service_id
    #   #     subresource_target  = "searchService"
    #   #     spark_enabled       = false
    #   #     spark_status        = "Inactive"
    #   #   }
    #   # }
    # }
  }


  # # example
  # encryption_key_id                    = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<key-vault-name>/keys/<key-name>"
  # encryption_key_vault_id              = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<key-vault-name>"
  # encryption_user_assigned_identity_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<identity-name>"


  # encryption {
  #   key_id                    = var.encryption_key_id
  #   key_vault_id              = var.encryption_key_vault_id
  #   user_assigned_identity_id = var.encryption_user_assigned_identity_id
  # }


  identity {
    type = "SystemAssigned"
  }
}

# configure ai hub outbound rules to search services and ai services
resource "azapi_update_resource" "ai_hub_update" {
  type       = "Microsoft.MachineLearningServices/workspaces@2024-07-01-preview"
  resource_id = azurerm_ai_foundry.this.id
  
  body = {
    properties = {
      managedNetwork = {
        outboundRules = local.base_ai_hub_outbound_rules # var.ai_hub_outbound_rules
      }
    }
  }

  depends_on = [
    azurerm_ai_foundry.this,
    module.searchservice.resource,
    azurerm_ai_foundry.this,
  ]
}


resource "azurerm_monitor_diagnostic_setting" "aihub_diagnostics_settings" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? "${each.value.name}-aihub" : "diag-${var.name}-aihub" 
  target_resource_id             = azurerm_ai_foundry.this.id
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
