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

# resource "azurerm_stream_analytics_managed_private_endpoint" "sqlserver" {
#   name                          = "saprivateendpointsqlserver"
#   resource_group_name           = var.resource_group_name
#   stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
#   target_resource_id            = var.sql_server_id
#   subresource_name              = "sqlserver"
# }

resource "azurerm_stream_analytics_managed_private_endpoint" "dataexplorer" {
  name                          = "saprivateendpointdataexplorer"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  target_resource_id            = var.data_explorer_id
  subresource_name              = "cluster"
}

resource "azurerm_stream_analytics_managed_private_endpoint" "eventhubs" {
  name                          = "saprivateendpointeventhubs"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  target_resource_id            = var.event_hub_id
  subresource_name              = "namespace"
}

resource "azurerm_stream_analytics_managed_private_endpoint" "iothub" {
  name                          = "saprivateendpointiothub"
  resource_group_name           = var.resource_group_name
  stream_analytics_cluster_name = azurerm_stream_analytics_cluster.this.name
  target_resource_id            = var.iot_hub_id
  subresource_name              = "events"
}