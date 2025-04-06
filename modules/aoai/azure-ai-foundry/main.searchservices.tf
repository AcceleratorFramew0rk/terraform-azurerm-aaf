module "searchservice" {
  # source  = "./../../../../../../modules/terraform-azurerm-aaf/modules/cognitive_services/terraform-azurerm-searchservice"
  source = "AcceleratorFramew0rk/aaf/azurerm//modules/cognitive_services/terraform-azurerm-searchservice"
  
  name                         = "${var.base_name}-searchservices" # "${module.naming.search_service.name}-${random_string.this.result}" # alpha numeric characters only are allowed in "name var.name_prefix == null ? "${random_string.prefix.result}${var.acr_name}" : "${var.name_prefix}${var.acr_name}"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  sku                 = "standard" # try(var.sku, "standard")
  # A system assigned identity must be provided even though the AzureRM provider states it is optional.
  managed_identities = {
    system_assigned = true
  }

  tags        = var.tags  
}



resource "azurerm_private_dns_zone" "searchservice_dns_zone" {
  name           = "privatelink.search.windows.net"
  resource_group_name           = var.resource_group_name
}


resource "azurerm_private_dns_zone_virtual_network_link" "searchservice_dns_link" {
  name                   = "dns-link-${azurerm_private_dns_zone.searchservice_dns_zone.name}"
  resource_group_name    = var.resource_group_name
  private_dns_zone_name  = azurerm_private_dns_zone.searchservice_dns_zone.name
  virtual_network_id     = var.vnet_id # try(local.remote.networking.virtual_networks.spoke_project.virtual_network.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_network.id : var.vnet_id  
  registration_enabled   = false
}

// private endpoint - ServiceSubnet
resource "azurerm_private_endpoint" "searchservice_private_endpoint" {
  name                = "pep-${module.searchservice.resource.name}"
  location                      = var.location 
  resource_group_name           = var.resource_group_name
  subnet_id      = var.private_endpoint_subnet_id # try(local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id, null) != null ? local.remote.networking.virtual_networks.spoke_project.virtual_subnets[var.subnet_name].resource.id : var.subnet_id

  private_service_connection {
    name                           = "searchserviceConnection"
    private_connection_resource_id = module.searchservice.resource.id
    subresource_names              = ["searchService"]
    is_manual_connection           = false
  }


  private_dns_zone_group {
    name = "searchservice-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.searchservice_dns_zone.id] // If needed
  }
}

