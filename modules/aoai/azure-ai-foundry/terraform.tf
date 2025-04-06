provider "azurerm" {
  features {}
}

# Configure Terraform backend
terraform {
  required_version = "~> 1.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4, < 5.0.0"
    }
    azapi = {
      source = "azure/azapi"
    }    
  }
  backend "azurerm" {}
}
