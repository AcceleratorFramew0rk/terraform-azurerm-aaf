variable "name" {
  description = "(Required) Specifies the name of the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Container Registry. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "app_settings" {
  description = "Application settings"
  default = null
}

variable "site_config" {
  description = "site_config"
  default = {}
}

variable "subnet_id" {
  description = "subnet_id"
  type        = string  
}

variable "app_service_plan_id" {
  description = "app_service_plan_id"
  type        = string  
}

variable "storage_account_name" {
  description = "storage_account_name"
  type        = string  
  default = null
}

variable "storage_account_access_key" {
  description = "storage_account_access_key"
  type        = string  
  default = null
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Custom tags to apply to the resource."
}

variable "identity" {
  default = {}
}