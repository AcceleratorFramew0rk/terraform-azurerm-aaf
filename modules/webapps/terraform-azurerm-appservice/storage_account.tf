resource "azurerm_storage_account" "storage" {
  name                     = replace("${var.name}sa", "-", "") 
  location            = var.location 
  resource_group_name = var.resource_group_name 
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "containerbackup" {
  name                  = "backup"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "containerlogs" {
  name                  = "logs"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "containerhttplogs" {
  name                  = "httplogs"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

data "azurerm_storage_account_blob_container_sas" "backup" {
  count = try(var.backup, null) != null ? 1 : 0

  connection_string = azurerm_storage_account.storage.primary_connection_string 
  container_name    = azurerm_storage_container.containerbackup.name 
  https_only        = true

  start  = time_rotating.sas[0].id
  expiry = timeadd(time_rotating.sas[0].id, format("%sh", try(var.backup.sas_policy.expire_in_days, 7) * 24))

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

data "azurerm_storage_account_blob_container_sas" "logs" {
  count = try(var.logs, null) != null ? 1 : 0

  connection_string = azurerm_storage_account.storage.primary_connection_string  
  container_name    = azurerm_storage_container.containerlogs.name 
  https_only        = true

  start  = time_rotating.logs_sas[0].id
  expiry = timeadd(time_rotating.logs_sas[0].id, format("%sh", try(var.logs.sas_policy.expire_in_days, 7) * 24))

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}


data "azurerm_storage_account_blob_container_sas" "http_logs" {

  count = try(var.logs.http_logs, null) != null ? 1 : 0

  connection_string = azurerm_storage_account.storage.primary_connection_string  
  container_name    = azurerm_storage_container.containerhttplogs.name 
  https_only        = true

  start  = time_rotating.http_logs_sas[0].id
  expiry = timeadd(time_rotating.http_logs_sas[0].id, format("%sh", try(var.logs.http_logs.sas_policy.expire_in_days, 7) * 24))

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

resource "time_rotating" "sas" {

  count = try(var.backup.sas_policy, null) != null ? 1 : 0

  rotation_minutes = lookup(var.backup.sas_policy.rotation, "mins", null)
  rotation_days    = lookup(var.backup.sas_policy.rotation, "days", null)
  rotation_months  = lookup(var.backup.sas_policy.rotation, "months", null)
  rotation_years   = lookup(var.backup.sas_policy.rotation, "years", null)
}

resource "time_rotating" "logs_sas" {

  count = try(var.logs.sas_policy, null) != null ? 1 : 0

  rotation_minutes = lookup(var.logs.sas_policy.rotation, "mins", null)
  rotation_days    = lookup(var.logs.sas_policy.rotation, "days", null)
  rotation_months  = lookup(var.logs.sas_policy.rotation, "months", null)
  rotation_years   = lookup(var.logs.sas_policy.rotation, "years", null)
}

resource "time_rotating" "http_logs_sas" {

  count = try(var.logs.http_logs.sas_policy, null) != null ? 1 : 0

  rotation_minutes = lookup(var.logs.http_logs.sas_policy.rotation, "mins", null)
  rotation_days    = lookup(var.logs.http_logs.sas_policy.rotation, "days", null)
  rotation_months  = lookup(var.logs.http_logs.sas_policy.rotation, "months", null)
  rotation_years   = lookup(var.logs.http_logs.sas_policy.rotation, "years", null)
}
