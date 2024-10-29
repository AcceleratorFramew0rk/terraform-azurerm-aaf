# outputs.tf
output "id" {
  description = "The ID of the IoT Hub."
  value       = azurerm_iothub.iot_hub.id
}

output "name" {
  description = "The name of the IoT Hub."
  value       = azurerm_iothub.iot_hub.name
}

output "resource" {
  description = "The resource of the IoT Hub."
  value       = azurerm_iothub.iot_hub
}

