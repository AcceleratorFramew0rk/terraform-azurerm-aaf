output "kusto_cluster_id" {
  description = "The ID of the Kusto Cluster."
  value       = azurerm_kusto_cluster.this.id
}

output "kusto_cluster_name" {
  description = "The name of the Kusto Cluster."
  value       = azurerm_kusto_cluster.this.name
}

output "resource" {
  description = "The resource of the IoT Hub."
  value       = azurerm_kusto_cluster.this
}

