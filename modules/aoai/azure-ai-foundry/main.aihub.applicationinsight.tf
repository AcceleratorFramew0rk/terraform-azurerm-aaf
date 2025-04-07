
resource "azurerm_application_insights" "this" {
  name                     = "${var.base_name}-appinsight"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  workspace_id = var.log_analytics_workspace_id
  application_type    = "web"
  tags = var.tags
}


resource "azurerm_monitor_diagnostic_setting" "appinsight_diagnostics_settings" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? "${each.value.name}-appinsight" : "diag-${var.name}-appinsight" 
  target_resource_id             = azurerm_application_insights.this.id
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
