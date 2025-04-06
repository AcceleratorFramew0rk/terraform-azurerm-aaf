

resource "azurerm_storage_account" "this" {
  name                     = "${replace(var.base_name,"-","")}st" # "${module.naming.storage_account.name_unique}st${random_string.this.result}"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
