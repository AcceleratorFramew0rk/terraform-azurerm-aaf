# main.tf
provider "azurerm" {
  features {}
}

resource "azurerm_storage_account" "this" {
  name                     = "stsatostpvtep01"
  resource_group_name = var.resource_group_name
  location            = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_stream_analytics_cluster" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  streaming_capacity  = 36

}

resource "azurerm_stream_analytics_job" "adl_asa" {

  count = var.module_enabled ? 1 : 0

  name                                     = "asa-${var.name}"
  resource_group_name                      = var.resource_group_name
  location                                 = var.location
  compatibility_level                      = var.compatibility_level
  data_locale                              = var.data_locale
  events_late_arrival_max_delay_in_seconds = var.events_late_arrival_max_delay_in_seconds
  events_out_of_order_max_delay_in_seconds = var.events_out_of_order_max_delay_in_seconds
  events_out_of_order_policy               = var.events_out_of_order_policy
  output_error_policy                      = var.output_error_policy
  streaming_units                          = var.streaming_units
  transformation_query                     = <<QUERY
    SELECT *
    INTO [YourOutputAlias]
    FROM [YourInputAlias]
QUERY
  tags                                     = var.tags

}

# IoT Hub: events
# Event Hubs: namespace
# SQL Server: sqlServer
# Azure Data Explorer (Kusto): cluster

resource "azurerm_stream_analytics_managed_private_endpoint" "blob" {
  name                          = "saprivateendpointblob"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  target_resource_id            = azurerm_storage_account.this.id
  subresource_name              = "blob"
}

resource "azurerm_stream_analytics_managed_private_endpoint" "sqlserver" {
  count                         = var.sql_server_id != "" && var.sql_server_id != null ? 1 : 0

  name                          = "saprivateendpointsqlserver"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  target_resource_id            = var.sql_server_id
  subresource_name              = "sqlServer"
}

resource "azurerm_stream_analytics_managed_private_endpoint" "dataexplorer" {
  count                         = var.data_explorer_id != "" && var.data_explorer_id != null ? 1 : 0

  name                          = "saprivateendpointdataexplorer"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  target_resource_id            = var.data_explorer_id
  subresource_name              = "cluster"
}

resource "azurerm_stream_analytics_managed_private_endpoint" "eventhubs" {
  count                         = var.eventhub_namespace_id != "" && var.eventhub_namespace_id != null ? 1 : 0

  name                          = "saprivateendpointeventhubs"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  target_resource_id            = var.eventhub_namespace_id 
  subresource_name              = "namespace"
}

resource "azurerm_stream_analytics_managed_private_endpoint" "iothub" {
  count                         = var.iot_hub_id != "" && var.iot_hub_id != null ? 1 : 0

  name                          = "saprivateendpointiothub"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  # Check Resource Type: Ensure that the resource type is correctly specified. It should be Microsoft.Devices/IotHubs (case-sensitive).
  target_resource_id            = var.iot_hub_id 
  subresource_name              = "iotHub" 
}


# # # Approved via Azure CLI
# # az network private-endpoint-connection approve \
# #   --id /subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Devices/IotHubs/{iot-hub-name}/privateEndpointConnections/{private-connection-name} \
# #   --description "Approving private endpoint for Stream Analytics"
# #      az iot hub device-identity create --hub-name ${module.iot_hub.name} --device-id myDevice1
# resource "null_resource" "approved_iothub_privateendpoint" {
#   provisioner "local-exec" {
#     command = <<EOT
#       az network private-endpoint-connection approve \
#         --id ${azurerm_stream_analytics_managed_private_endpoint.iothub[0].id} \
#         --description "Approving private endpoint for Stream Analytics"
#     EOT
#   }
#   depends_on = [azurerm_stream_analytics_managed_private_endpoint.iothub]
# }