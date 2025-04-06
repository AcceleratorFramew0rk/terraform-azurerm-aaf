
# resource "azurerm_ai_foundry_project" "this" {
#   name               = "${var.base_name}-project1"
#   location           = azurerm_ai_foundry.this.location
#   ai_services_hub_id = azurerm_ai_foundry.this.id

#   depends_on = [
#     azurerm_ai_foundry.this,
#   ]
# }


// Azure AI Project
resource "azapi_resource" "project" {
  type      = "Microsoft.MachineLearningServices/workspaces@2024-04-01-preview"
  name      = "${var.base_name}-project1"
  location                      = var.location 
  parent_id           = var.resource_group_id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      description   = "This is my Azure AI PROJECT"
      friendlyName  = "My Project"
      hubResourceId = azurerm_ai_foundry.this.id # azapi_resource.ai_hub.id
    }
    kind = "project"
  }
}
