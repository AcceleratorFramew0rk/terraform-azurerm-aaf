

data "azurerm_client_config" "current" {}


# This allow use to randomize the name of resources
resource "random_string" "this" {
  length  = 3
  special = false
  upper   = false
}

locals {
  base_shared_private_links = [
    {
      groupId               = "blob"
      status                = "Approved"
      provisioningState     = "Succeeded"
      requestMessage        = "created using the Terraform template"
      privateLinkResourceId = azurerm_storage_account.this.id # lookup(module.ai_foundry_core[0], "ml_storage_id", null)
    },
    {
      groupId               = "cognitiveservices_account"
      status                = "Approved"
      provisioningState     = "Succeeded"
      requestMessage        = "created using the Terraform template"
      privateLinkResourceId = azurerm_ai_services.this.id # lookup(module.ai_foundry_services[0], "aiServicesId", null)
    }
  ]

  base_ai_hub_outbound_rules = {
    search = {
      type = "PrivateEndpoint"
      destination = {
        serviceResourceId = module.searchservice.resource.id # lookup(module.ai_foundry_services[0], "search_service_id", null)
        subresourceTarget = "searchService"
        sparkEnabled      = false
        sparkStatus       = "Inactive"
      }
    }
    aiservices = {
      type = "PrivateEndpoint"
      destination = {
        serviceResourceId = azurerm_ai_services.this.id # lookup(module.ai_foundry_services[0], "aiServicesId", null)
        subresourceTarget = "account"
        sparkEnabled      = false
        sparkStatus       = "Inactive"
      }
    }
  }
}
