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

variable "sql_server_id" {
  description = "ID of the SQL Server."
  type        = string
  default = ""
}

variable "data_explorer_id" {
  description = "ID of the data_explorer ."
  type        = string
}

variable "event_hub_id" {
  description = "ID of the event_hub."
  type        = string
}

variable "iot_hub_id" {
  description = "ID of the iot_hub."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
