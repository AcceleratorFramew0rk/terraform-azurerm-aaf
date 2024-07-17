locals {

  backup_container_key = "backup"
  backup_storage_account = try(var.backup, null) != null ? azurerm_storage_account.storage : null 
  backup_sas_url         = try(var.backup, null) != null ? "${local.backup_storage_account.primary_blob_endpoint}${azurerm_storage_container.containerbackup.name}${data.azurerm_storage_account_blob_container_sas.backup[0].sas}" : null

  logs_container_key = "logs"
  logs_storage_account = null # can(var.logs) ? azurerm_storage_account.storage : null # can(var.settings.backup) ? var.storage_accounts[try(var.settings.backup.lz_key, var.client_config.landingzone_key)][var.settings.backup.storage_account_key] : null
  logs_sas_url         = null # can(var.logs) ? "${local.logs_storage_account.primary_blob_endpoint}${azurerm_storage_container.containerlogs.name}${data.azurerm_storage_account_blob_container_sas.logs[0].sas}" : null

  http_logs_container_key = "http_logs"
  http_logs_storage_account = null # can(var.logs) ? azurerm_storage_account.storage : null # can(var.settings.backup) ? var.storage_accounts[try(var.settings.backup.lz_key, var.client_config.landingzone_key)][var.settings.backup.storage_account_key] : null
  http_logs_sas_url         = null # can(var.logs) ? "${local.http_logs_storage_account.primary_blob_endpoint}${azurerm_storage_container.containerhttplogs.name}${data.azurerm_storage_account_blob_container_sas.logs[0].sas}" : null


}