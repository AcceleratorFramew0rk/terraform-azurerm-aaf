resource "azurerm_storage_account" "this" {
  name                     = replace("${var.name}sa", "-", "") # "${var.name}sa" # "logicappsa" 
  resource_group_name      = var.resource_group_name
  location                 = var.location 
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_logic_app_standard" "logic_app_standard" {
  name                       = var.name 
  location                   = var.location 
  resource_group_name        = var.resource_group_name
  app_service_plan_id        = var.app_service_plan_id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key


  # An identity block supports the following:
  # type - (Required) Specifies the type of Managed Service Identity that should be configured on this Logic App Standard. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned (to enable both).
  # identity_ids - (Optional) Specifies a list of User Assigned Managed Identity IDs to be assigned to this Logic App Standard.
  dynamic "identity" {
    for_each = try(var.identity, null) != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids  
    }
  }

  app_settings = var.app_settings

  # add virtual_network_subnet_id - (Optional) The subnet id which will be used by this resource for regional virtual network integration.
  virtual_network_subnet_id = var.subnet_id 

  dynamic "site_config" {
    for_each = try(var.site_config, {}) != {} ? [1] : []
    # for_each = try(var.site_config, null) != null ? [var.identity] : []

    content {
      always_on                 = lookup(var.site_config, "enabled", null)
      dotnet_framework_version  = lookup(var.site_config, "dotnet_framework_version", null)
      ftps_state                = lookup(var.site_config, "ftps_state", null)
      http2_enabled             = lookup(var.site_config, "http2_enabled", null)
      linux_fx_version          = lookup(var.site_config, "linux_fx_version", null)
      min_tls_version           = lookup(var.site_config, "min_tls_version", null)
      use_32_bit_worker_process = lookup(var.site_config, "use_32_bit_worker_process", null)
      vnet_route_all_enabled    = lookup(var.site_config, "enabled", null)
      websockets_enabled        = lookup(var.site_config, "enabled", null)

      dynamic "cors" {
        for_each = lookup(var.site_config, "cors", {}) != {} ? [1] : []

        content {
          allowed_origins     = lookup(var.site_config.cors, "allowed_origins", null)
          support_credentials = lookup(var.site_config.cors, "support_credentials", null)
        }
      }
    }
  }
}

