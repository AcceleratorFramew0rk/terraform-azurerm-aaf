# insert your variables here
variable "name" {
  type        = string  
  default = "aifoundry"
}

variable "base_name" {
  type        = string  
  default = "aifoundry"
}

variable "location" {
  type        = string  
  default = "southeastasia"
}

variable "resource_group_name" {
  type        = string  
  default = null
}

variable "ai_services_location" {
  type        = string  
  default = "southeastasia"
}

variable "ai_services_resource_group_name" {
  type        = string  
  default = null
}

variable "resource_group_id" {
  type        = string  
  default = null
}

variable "log_analytics_workspace_id" {
  type        = string  
  default = null
}


# variable "tenant_id" {
#   type        = string  
#   default = null
# }

variable "vnet_id" {
  type        = string  
  default = null
}

# AISunet
variable "subnet_id" {
  type        = string  
  default = null
}


variable "tags" {
  description = "Tags to be applied to the resource"
  default     = null
}

# ServiceSubnet
variable "private_endpoint_subnet_id" {
  type        = string  
  default = null
}



# # --------------------------



# variable "prefix" {
#   type        = string  
#   default = "aaf"
# }

# variable "environment" {
#   type        = string  
#   default = "sandpit"
# }

# variable "subnet_name" {
#   type        = string  
#   default = "ServiceSubnet"
# }


# developer portal variables
# sku: Standard, Premium (default Premium)
# pep: yes (readonly)
# pte dns: yes (readonly)


# # encryption
# variable "encryption_key_id" {
#   description = "The ID of the encryption key to use for the AI Foundry resource."
#   type        = string
#   default     = null
# }

# variable "encryption_key_vault_id" {
#   description = "The ID of the Key Vault where the encryption key is stored."
#   type        = string
#   default     = null
# }

# variable "encryption_user_assigned_identity_id" {
#   description = "The ID of the user-assigned managed identity for accessing the encryption key."
#   type        = string
#   default     = null
# }
# # end encryption