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

variable "diagnostic_settings" {
  type = map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of diagnostic settings to create on the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Example Input:

```hcl
diagnostic_settings = {
  diag_setting_1 = {
    name                           = "diagSetting1"
    log_groups                     = ["allLogs"]
    metric_categories              = ["AllMetrics"]
    log_analytics_destination_type = null
    workspace_resource_id          = azurerm_log_analytics_workspace.this_workspace.id
  }
}
```
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue(
      [
        for _, v in var.diagnostic_settings :
        v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
      ]
    )
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id`, must be set."
  }
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