
resource "azurerm_ai_services" "this" {
  name                = "${var.base_name}ai-services-${random_string.this.result}" # "ai-services-${random_string.this.result}" # "thisaiservices"
  # this resource group name must be in the same region as the service account eastus
  location                      = var.ai_services_location # hardcoded to eastus 
  resource_group_name           = var.ai_services_resource_group_name

  sku_name            = "S0" # Possible values are F0, F1, S0, S, S1, S2, S3, S4, S5, S6, P0, P1, P2, E0 and DC0.
  identity {
    type = "SystemAssigned"
  }

  outbound_network_access_restricted = false # true or false
  public_network_access = "Disabled" # "Enabled" or "Disabled"
  custom_subdomain_name = "aiservices-${var.base_name}-${random_string.this.result}" # ramdom

  storage {
      storage_account_id = azurerm_storage_account.this.id 
    }

  tags = var.tags
}


resource "azurerm_private_endpoint" "ai_services_private_endpoint" {
  name                           = "${var.base_name}-pep-aiservices"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.base_name}-connection-aiservices"
    private_connection_resource_id = azurerm_ai_services.this.id # azapi_resource.ai_services.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "ai-services-dns-group"

    private_dns_zone_ids = [
        azurerm_private_dns_zone.cognitive_services.id,
        azurerm_private_dns_zone.openai.id,
        azurerm_private_dns_zone.services_ai.id
      ]
  }
  tags = var.tags
}
