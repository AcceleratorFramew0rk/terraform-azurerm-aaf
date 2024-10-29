output "eventhub_namespace_id" {
  description = "The ID of the Event Hub Namespace."
  value       = azurerm_eventhub_namespace.this.id
}

output "id" {
  description = "The ID of the Event Hub."
  value       = azurerm_eventhub.this.id
}

output "resource" {
  description = "The ID of the Event Hub."
  value       = azurerm_eventhub.this
}

