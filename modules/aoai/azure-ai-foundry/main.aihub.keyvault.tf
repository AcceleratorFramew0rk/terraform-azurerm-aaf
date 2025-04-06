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
