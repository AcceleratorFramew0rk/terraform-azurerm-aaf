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
