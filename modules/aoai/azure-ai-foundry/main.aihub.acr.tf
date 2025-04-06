

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


resource "azurerm_monitor_diagnostic_setting" "acr_diagnostics_settings" {
  for_each = var.diagnostic_settings

  name                           = each.value.name != null ? "${each.value.name}-acr" : "diag-${var.name}-acr" 
  target_resource_id             = azurerm_container_registry.this.id
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

# resource "azurerm_monitor_diagnostic_setting" "acr_diagnostic" {
#   name                           = "${var.name}-amds-acr"
#   target_resource_id             = azurerm_container_registry.this.id
#   log_analytics_destination_type = "Dedicated"
#   # TODO
#   log_analytics_workspace_id     = var.log_analytics_workspace_id

#   # Kubernetes API Server
#   enabled_log {
#     category = "kube-apiserver"
#   }
#   # Kubernetes Audit
#   enabled_log {
#     category = "kube-audit"
#   }
#   # Kubernetes Audit Admin Logs
#   enabled_log {
#     category = "kube-audit-admin"
#   }
#   # Kubernetes Controller Manager
#   enabled_log {
#     category = "kube-controller-manager"
#   }
#   # Kubernetes Scheduler
#   enabled_log {
#     category = "kube-scheduler"
#   }
#   #Kubernetes Cluster Autoscaler
#   enabled_log {
#     category = "cluster-autoscaler"
#   }
#   #Kubernetes Cloud Controller Manager
#   enabled_log {
#     category = "cloud-controller-manager"
#   }
#   #guard
#   enabled_log {
#     category = "guard"
#   }
#   #csi-azuredisk-controller
#   enabled_log {
#     category = "csi-azuredisk-controller"
#   }
#   #csi-azurefile-controller
#   enabled_log {
#     category = "csi-azurefile-controller"
#   }
#   #csi-snapshot-controller
#   enabled_log {
#     category = "csi-snapshot-controller"
#   }
#   metric {
#     category = "AllMetrics"
#   }
# }