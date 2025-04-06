output "resource" {
  value       = azurerm_ai_foundry.this 
  description = "The Azure azurerm_ai_foundry resource"
  sensitive = true  
}

output "resource_search_services" {
  value       = module.searchservice.resource 
  description = "The Azure searchservice resource"
  sensitive = true  
}

output "resource_ai_services" {
  value       = azurerm_ai_services.this 
  description = "The Azure searchservice resource"
  sensitive = true  
}
