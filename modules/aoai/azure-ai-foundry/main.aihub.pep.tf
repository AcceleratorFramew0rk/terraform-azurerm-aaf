
// Private Endpoint for Machine Learning Workspace
resource "azurerm_private_endpoint" "ml_private_endpoint" {
  name                = "${azurerm_ai_foundry.this.name}-mlpep"
  location            = var.location 
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "amlworkspace-connection"
    private_connection_resource_id = azurerm_ai_foundry.this.id 
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "aml-dns-group"
    private_dns_zone_ids = [
        azurerm_private_dns_zone.aml_private_dns.id,
        azurerm_private_dns_zone.notebook_private_dns.id
    ]

  }

  tags = var.tags

  depends_on = [
    azurerm_private_dns_zone.services_ai,
    azurerm_private_dns_zone.openai,
    azurerm_private_dns_zone.cognitive_services,
  ]
}