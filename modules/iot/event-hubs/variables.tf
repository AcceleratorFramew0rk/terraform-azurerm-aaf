variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Location for the Event Hub."
  type        = string
}

variable "name" {
  description = "Name of the Event Hub."
  type        = string
}

variable "namespace_name" {
  description = "Name of the Event Hub Namespace."
  type        = string
}

variable "sku" {
  description = "SKU for the Event Hub Namespace."
  type        = string
  default     = "Standard"
}

variable "capacity" {
  description = "Capacity for the Event Hub Namespace."
  type        = number
  default     = 1
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
