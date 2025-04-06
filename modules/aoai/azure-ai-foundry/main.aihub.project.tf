
# resource "azurerm_ai_foundry_project" "this" {
#   name               = "${var.base_name}-project1"
#   location           = azurerm_ai_foundry.this.location
#   ai_services_hub_id = azurerm_ai_foundry.this.id

#   depends_on = [
#     azurerm_ai_foundry.this,
#   ]
# }


// Azure AI Project
resource "azapi_resource" "project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name      = "${var.base_name}-project1"
  location                      = var.location 
  parent_id           = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      description   = "This is my Azure AI PROJECT"
      friendlyName  = "My Project"
      hubResourceId = azurerm_ai_foundry.this.id # azapi_resource.ai_hub.id
    }
    kind = "project"
  }
}


resource "azurerm_monitor_diagnostic_setting" "aiproject_diagnostics_settings" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? "${each.value.name}-aiproject" : "diag-${var.name}-aiproject" 
  target_resource_id             = azapi_resource.project.id
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
