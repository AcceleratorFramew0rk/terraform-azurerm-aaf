output "eventhub_namespace_id" {
  description = "The ID of the Event Hub Namespace."
  value       = azurerm_stream_analytics_cluster.this.id
}

output "id" {
  description = "The ID of the Event Hub."
  value       = azurerm_stream_analytics_cluster.this.id
}

output "resource" {
  description = "The ID of the Event Hub."
  value       = azurerm_stream_analytics_cluster.this
}

