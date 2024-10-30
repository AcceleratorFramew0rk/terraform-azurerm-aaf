variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Location for the Kusto Cluster."
  type        = string
}

variable "name" {
  description = "Name of the Kusto Cluster."
  type        = string
}

variable "sku_name" {
  description = "The SKU of the cluster, e.g., 'Standard_D13_v2'."
  type        = string
  default     = "Standard_D13_v2"
}

variable "sku_capacity" {
  description = "The capacity of the SKU (number of instances)."
  type        = number
  default     = 2
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# azurerm_kusto_database variables
variable "soft_delete_period" {
  description = "The period data is kept in the database for soft deletion"
  type        = string
  default     = "P31D"
}

variable "hot_cache_period" {
  description = "The period data is kept in hot cache"
  type        = string
  default     = "P7D"
}