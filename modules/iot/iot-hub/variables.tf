# variables.tf
variable "name" {
  description = "The name of the IoT Hub."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the IoT Hub."
  type        = string
}

variable "location" {
  description = "The location where the IoT Hub will be created."
  type        = string
}

variable "sku" {
  description = "The SKU for the IoT Hub."
  type        = string
  default     = "S1"
}

variable "capacity" {
  description = "The capacity for the IoT Hub (number of units)."
  type        = number
  default     = 1
}

variable "public_network_access_enabled" {
  description = "The public network access enabled flag."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
