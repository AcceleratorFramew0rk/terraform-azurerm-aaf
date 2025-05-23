# TODO
module "avm_res_containerregistry_registry" {
  for_each                      = toset(var.acr == null ? [] : ["acr"])
  source                        = "Azure/avm-res-containerregistry-registry/azurerm"
  version                       = "0.4.0"
  name                          = var.acr.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Premium"
  public_network_access_enabled = false
  private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = var.acr.private_dns_zone_resource_ids
      subnet_resource_id            = var.acr.subnet_resource_id
    }
  }
}

resource "azurerm_role_assignment" "acr" {
  for_each = toset(var.acr == null ? [] : ["acr"])

  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  scope                            = module.avm_res_containerregistry_registry["acr"].resource_id
  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
}

# TODO
# resource "azurerm_role_assignment" "acr_identity" {
#   count = length(var.container_registry_id) > 0 ? 1 : 0
# 
#   principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
#   scope                            = try(var.container_registry_id, null) == null ? module.avm_res_containerregistry_registry[0].resource_id : var.container_registry_id
#   role_definition_name             = "AcrPull"
#   skip_service_principal_aad_check = true
# }


resource "azurerm_user_assigned_identity" "aks" {
  count = length(var.managed_identities.user_assigned_resource_ids) > 0 ? 0 : 1

  location            = var.location
  name                = "uami-aks"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# TODO
# data "azurerm_resource_group" "this" {
#   name = var.resource_group_name
# }

data "azurerm_user_assigned_identity" "cluster_identity" {
  name                = split("/", one(local.managed_identities.user_assigned.this.user_assigned_resource_ids))[8]
  # TODO
  resource_group_name = var.resource_group_name # data.azurerm_resource_group.this.name
}

resource "azurerm_role_assignment" "network_contributor_on_resource_group" {
  principal_id         = data.azurerm_user_assigned_identity.cluster_identity.principal_id
  # TODO
  scope                = var.resource_group_id
  # scope                = data.azurerm_resource_group.this.id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "dns_zone_contributor" {
  count = var.private_dns_zone_id_enabled ? 1 : 0

  principal_id         = data.azurerm_user_assigned_identity.cluster_identity.principal_id
  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
}

resource "azurerm_kubernetes_cluster" "this" {
  location                          = var.location
  # TODO
  name                              = var.name # "aks-${var.name}"
  resource_group_name               = var.resource_group_name
  automatic_upgrade_channel         = "patch"
  azure_policy_enabled              = true
  dns_prefix                        = var.name
  kubernetes_version                = var.kubernetes_version
  local_account_disabled            = true
  node_os_upgrade_channel           = "NodeImage"
  oidc_issuer_enabled               = true
  private_cluster_enabled           = true
  private_dns_zone_id               = var.private_dns_zone_id
  role_based_access_control_enabled = true
  sku_tier                          = "Standard"
  tags                              = var.tags
  workload_identity_enabled         = true
  # TODO
  node_resource_group               = var.node_resource_group

  service_mesh_profile {
    mode = "Istio"
    revisions = ["asm-1-23"] # ["asm-1-22"] # null # leave it empty (the revisions will only be known after apply).
  }

  default_node_pool {
    name                    = "agentpool"
    vm_size                 = var.default_node_pool_vm_sku
    auto_scaling_enabled    = true
    # TODO:
    host_encryption_enabled = false # true
    max_count               = 9
    max_pods                = 110
    min_count               = 3
    node_labels             = var.node_labels
    orchestrator_version    = var.orchestrator_version
    os_sku                  = var.os_sku
    tags                    = merge(var.tags, var.agents_tags)
    vnet_subnet_id          = var.network.node_subnet_id
    zones                   = local.default_node_pool_available_zones

    upgrade_settings {
      max_surge = "10%"
    }
  }
  auto_scaler_profile {
    balance_similar_node_groups = true
  }
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = var.rbac_aad_admin_group_object_ids
    azure_rbac_enabled     = var.rbac_aad_azure_rbac_enabled
    tenant_id              = var.rbac_aad_tenant_id
  }
  ## Resources that only support UserAssigned
  dynamic "identity" {
    for_each = local.managed_identities.user_assigned

    content {
      type         = identity.value.type
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  monitor_metrics {
    annotations_allowed = try(var.monitor_metrics.annotations_allowed, null)
    labels_allowed      = try(var.monitor_metrics.labels_allowed, null)
  }
  network_profile {
    network_plugin      = "azure"
    load_balancer_sku   = "standard"
    network_plugin_mode = "overlay"
    network_policy      = "calico"
    pod_cidr            = var.network.pod_cidr # var.pod_cidr
    # TODO
    dns_service_ip      = var.network.dns_service_ip
    service_cidr        = var.network.service_cidr
  }
  oms_agent {
    # TODO
    log_analytics_workspace_id      = var.log_analytics_workspace_id # azurerm_log_analytics_workspace.this.id
    msi_auth_for_monitoring_enabled = true
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version
    ]

    precondition {
      condition     = var.kubernetes_version == null || try(can(regex("^[0-9]+\\.[0-9]+$", var.kubernetes_version)), false)
      error_message = "Ensure that kubernetes_version does not specify a patch version"
    }
    precondition {
      condition     = var.orchestrator_version == null || try(can(regex("^[0-9]+\\.[0-9]+$", var.orchestrator_version)), false)
      error_message = "Ensure that orchestrator_version does not specify a patch version"
    }
    precondition {
      condition     = var.private_dns_zone_id == null ? true : (anytrue([for r in local.valid_private_dns_zone_regexs : try(regex(r, local.private_dns_zone_name) == local.private_dns_zone_name, false)]))
      error_message = "According to the [document](https://learn.microsoft.com/en-us/azure/aks/private-clusters?tabs=azure-portal#configure-a-private-dns-zone), the private DNS zone must be in one of the following format: `privatelink.<region>.azmk8s.io`, `<subzone>.privatelink.<region>.azmk8s.io`, `private.<region>.azmk8s.io`, `<subzone>.private.<region>.azmk8s.io`"
    }
    precondition {
      condition     = var.private_dns_zone_id != null ? var.private_dns_zone_id_enabled == true : var.private_dns_zone_id_enabled == false
      error_message = "private_dns_zone_id must be set if private_dns_zone_id_enabled is true"
    }
  }
}

# The following null_resource is used to trigger the update of the AKS cluster when the kubernetes_version changes
# This is necessary because the azurerm_kubernetes_cluster resource ignores changes to the kubernetes_version attribute
# because AKS patch versions are upgraded automatically by Azure
# The kubernetes_version_keeper and aks_cluster_post_create resources implement a mechanism to force the update
# when the minor kubernetes version changes in var.kubernetes_version

resource "null_resource" "kubernetes_version_keeper" {
  triggers = {
    version = var.kubernetes_version
  }
}

resource "azapi_update_resource" "aks_cluster_post_create" {
  type = "Microsoft.ContainerService/managedClusters@2024-02-01"
  body = {
    properties = {
      kubernetesVersion = var.kubernetes_version
    }
  }
  resource_id = azurerm_kubernetes_cluster.this.id

  lifecycle {
    ignore_changes       = all
    replace_triggered_by = [null_resource.kubernetes_version_keeper.id]
  }
}

# TODO
# resource "azurerm_log_analytics_workspace" "this" {
#   location            = var.location
#   name                = "log-${var.name}-aks"
#   resource_group_name = var.resource_group_name
#   sku                 = "PerGB2018"
#   tags                = var.tags
# }

# resource "azurerm_log_analytics_workspace_table" "this" {
#   for_each = toset(local.log_analytics_tables)

#   name         = each.value
#   workspace_id = azurerm_log_analytics_workspace.this.id
#   plan         = "Basic"
# }

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                           = "amds-${var.name}-aks"
  target_resource_id             = azurerm_kubernetes_cluster.this.id
  log_analytics_destination_type = "Dedicated"
  # TODO
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  # Kubernetes API Server
  enabled_log {
    category = "kube-apiserver"
  }
  # Kubernetes Audit
  enabled_log {
    category = "kube-audit"
  }
  # Kubernetes Audit Admin Logs
  enabled_log {
    category = "kube-audit-admin"
  }
  # Kubernetes Controller Manager
  enabled_log {
    category = "kube-controller-manager"
  }
  # Kubernetes Scheduler
  enabled_log {
    category = "kube-scheduler"
  }
  #Kubernetes Cluster Autoscaler
  enabled_log {
    category = "cluster-autoscaler"
  }
  #Kubernetes Cloud Controller Manager
  enabled_log {
    category = "cloud-controller-manager"
  }
  #guard
  enabled_log {
    category = "guard"
  }
  #csi-azuredisk-controller
  enabled_log {
    category = "csi-azuredisk-controller"
  }
  #csi-azurefile-controller
  enabled_log {
    category = "csi-azurefile-controller"
  }
  #csi-snapshot-controller
  enabled_log {
    category = "csi-snapshot-controller"
  }
  metric {
    category = "AllMetrics"
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_kubernetes_cluster.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}


resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = tomap({
    for pool in local.node_pools : pool.name => pool
  })

  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  name                  = "np${each.value.name}"
  vm_size               = each.value.vm_size
  auto_scaling_enabled  = true
  max_count             = each.value.max_count
  min_count             = each.value.min_count
  node_labels           = each.value.labels
  orchestrator_version  = each.value.orchestrator_version
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_sku                = each.value.os_sku
  tags                  = each.value.tags
  # TODO
  vnet_subnet_id        = each.value.vnet_subnet_id # var.network.node_subnet_id
  zones                 = each.value.zone

  depends_on = [azapi_update_resource.aks_cluster_post_create]

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z][a-z0-9]{0,11}$", each.value.name))
      error_message = "The name must begin with a lowercase letter, contain only lowercase letters and numbers, and be between 1 and 12 characters in length."
    }
  }
}

# Data source for the current subscription
data "azurerm_subscription" "current" {}

data "azapi_resource_list" "example" {
  parent_id = data.azurerm_subscription.current.id
  type      = "Microsoft.Compute/Skus@2021-07-01"
  query_parameters = {
    "$filter" = [format("location eq '%s'", var.location)]
  }
  response_export_values = ["*"]
}

# # These resources allow the use of consistent local data files, and semver versioning
# data "local_file" "compute_provider" {
#   filename = "${path.module}/data/microsoft.compute_resourceTypes.json"
# }

# data "local_file" "locations" {
#   filename = "${path.module}/data/locations.json"
# }

# TODO: comment off vnet and passin subnet id

# module "vnet" {
#   source  = "Azure/subnets/azurerm"
#   version = "1.0.0"

#   resource_group_name = var.resource_group_name
#   subnets = {
#     nodecidr = {
#       address_prefixes = var.node_cidr != null ? [var.node_cidr] : ["10.31.0.0/16"]
#     }
#   }
#   virtual_network_address_space = var.node_cidr != null ? [var.node_cidr] : ["10.31.0.0/16"]
#   virtual_network_location      = var.location
#   virtual_network_name          = "vnet"
# }