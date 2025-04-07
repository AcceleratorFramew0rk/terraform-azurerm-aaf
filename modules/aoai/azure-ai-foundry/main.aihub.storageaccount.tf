

resource "azurerm_storage_account" "this" {
  name                     = "${replace(var.base_name,"-","")}st" # "${module.naming.storage_account.name_unique}st${random_string.this.result}"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  public_network_access_enabled = false
  tags = var.tags
}


# Enable Diagnostic Settings for Storage account
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  for_each = var.diagnostic_settings

  name                       = each.value.name
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id     = each.value.workspace_resource_id

  dynamic "metric" {
    for_each = each.value.metric_categories
    content {
      category = metric.value
    }
  }
}
# Enable Diagnostic Settings for Blob
resource "azurerm_monitor_diagnostic_setting" "blob" {
  for_each = var.diagnostic_settings

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default/"
  log_analytics_workspace_id     = each.value.workspace_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
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

# Enable Diagnostic Settings for Queue
resource "azurerm_monitor_diagnostic_setting" "queue" {
  for_each = var.diagnostic_settings

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/queueServices/default/"
  log_analytics_workspace_id     = each.value.workspace_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
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
# Enable Diagnostic Settings for Table
resource "azurerm_monitor_diagnostic_setting" "table" {
  for_each = var.diagnostic_settings

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/tableServices/default/"
  log_analytics_workspace_id     = each.value.workspace_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
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
# Enable Diagnostic Settings for Azure Files
resource "azurerm_monitor_diagnostic_setting" "azure_file" {
  for_each = var.diagnostic_settings

  name                       = each.value.name
  target_resource_id         = "${azurerm_storage_account.this.id}/fileServices/default/"
  log_analytics_workspace_id     = each.value.workspace_resource_id

  dynamic "enabled_log" {
    for_each = each.value.log_categories
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


