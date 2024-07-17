output "endpoint" {
  value = azurerm_cosmosdb_account.cosmosdb.endpoint
}

output "key" {
  value = azurerm_cosmosdb_account.cosmosdb.primary_key
}

output "connection_string" {
  value = azurerm_cosmosdb_account.cosmosdb.connection_strings[0]
}

output "name" {
  value = azurerm_cosmosdb_account.cosmosdb.name
}