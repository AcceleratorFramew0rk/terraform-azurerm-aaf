
resource "azurerm_application_insights" "this" {
  name                     = "${var.base_name}-appinsight"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  workspace_id = var.log_analytics_workspace_id
  application_type    = "web"
}
