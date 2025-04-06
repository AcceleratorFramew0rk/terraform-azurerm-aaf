# resource "azurerm_search_shared_private_link_service" "test" {
#   name               = "example-spl"
#   search_service_id  = azurerm_search_service.test.id
#   subresource_name   = "blob"
#   target_resource_id = azurerm_storage_account.test.id
#   request_message    = "please approve"
# }


# // Shared Private Link Resources
resource "azurerm_search_shared_private_link_service" "shared_private_link0" {

  name                = "search-shared-private-link-0"
  search_service_id   = module.searchservice.resource.id 
  subresource_name    = local.base_shared_private_links[0].groupId
  target_resource_id  = local.base_shared_private_links[0].privateLinkResourceId
  request_message     = local.base_shared_private_links[0].requestMessage

  depends_on = [
    azurerm_ai_services.this,
    azurerm_storage_account.this,
    module.searchservice,
    null_resource.pause_before_next,
   ]
}

resource "azurerm_search_shared_private_link_service" "shared_private_link1" {

  name                = "search-shared-private-link-1"
  search_service_id   = module.searchservice.resource.id 
  subresource_name    = local.base_shared_private_links[1].groupId
  target_resource_id  = local.base_shared_private_links[1].privateLinkResourceId
  request_message     = local.base_shared_private_links[1].requestMessage

  depends_on = [
    azurerm_ai_services.this,
    azurerm_storage_account.this,
    module.searchservice,
    azurerm_search_shared_private_link_service.shared_private_link0,
    null_resource.pause_before_next,
   ]
}


resource "null_resource" "pause_before_next" {
  # count = try(local.base_shared_private_links, null) != null ? length(local.base_shared_private_links) : 0

  provisioner "local-exec" {
    command = "sleep 5"
    interpreter = ["/bin/sh", "-c"]
  }
}
/*

resource "null_resource" "approve_private_link" {
  count = var.shared_private_link.deploy_shared_private_link ? length(var.shared_private_link.shared_private_links) : 0

  provisioner "local-exec" {
    command = var.os_type == "windows" ? join("\n", [
      "$resourceGroup = (${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} -split '/')[4]",
      "az network private-endpoint-connection approve --resource-group $resourceGroup --name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].name} --resource-name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} --type Microsoft.Search/searchServices/privateLinkResources --description 'Auto-approved by Terraform'"
    ]) : join("\n", [
      "RESOURCE_GROUP=$(echo ${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} | grep -o -P '(?<=resourceGroups/)[^/]+' | head -1)",
      "az network private-endpoint-connection approve --resource-group $RESOURCE_GROUP --name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].name} --resource-name ${azurerm_search_shared_private_link_service.shared_private_link[count.index].target_resource_id} --type Microsoft.Search/searchServices/privateLinkResources --description 'Auto-approved by Terraform'"
    ])
    interpreter = var.os_type == "windows" ? ["PowerShell", "-Command"] : ["/bin/sh", "-c"]
  }

  depends_on = [azurerm_search_shared_private_link_service.shared_private_link]
}*/

