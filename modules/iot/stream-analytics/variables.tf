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

variable "eventhub_namespace_id" {
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


# stream analytics job variables
variable "module_enabled" {
  type        = bool
  description = "Variable to enable or disable the module."
  default     = true
}

variable "compatibility_level" {
  type        = string
  description = "Specifies the compatibility level for this job - which controls certain runtime behaviours of the streaming job."
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.compatibility_level)
    error_message = "Valid values for compatibility_level are \"1.0\", \"1.1\", or \"1.2\"."
  }
  default = "1.2"
}

variable "data_locale" {
  type        = string
  description = "Specifies the Data Locale of the Job, which should be a supported .NET Culture."
  default     = "en-GB"
}

variable "events_late_arrival_max_delay_in_seconds" {
  type        = number
  description = "Specifies the maximum tolerable delay in seconds where events arriving late could be included."
  validation {
    condition     = var.events_late_arrival_max_delay_in_seconds >= -1 && var.events_late_arrival_max_delay_in_seconds <= 1814399 && floor(var.events_late_arrival_max_delay_in_seconds) == var.events_late_arrival_max_delay_in_seconds
    error_message = "Supported range is -1 (indefinite) to 1814399 (20d 23h 59m 59s)."
  }
  default = 60
}

variable "events_out_of_order_max_delay_in_seconds" {
  type        = number
  description = "Specifies the maximum tolerable delay in seconds where out-of-order events can be adjusted to be back in order."
  validation {
    condition     = var.events_out_of_order_max_delay_in_seconds >= 0 && var.events_out_of_order_max_delay_in_seconds <= 599 && floor(var.events_out_of_order_max_delay_in_seconds) == var.events_out_of_order_max_delay_in_seconds
    error_message = "Supported range is 0 to 599 (9m 59s)."
  }
  default = 50
}

variable "events_out_of_order_policy" {
  type        = string
  description = "Specifies the policy which should be applied to events which arrive out of order in the input event stream."
  validation {
    condition     = contains(["drop", "adjust"], lower(var.events_out_of_order_policy))
    error_message = "Valid values for events_out_of_order_policy are \"Drop\", or \"Adjust\"."
  }
  default = "Adjust"
}

variable "output_error_policy" {
  type        = string
  description = "Specifies the policy which should be applied to events which arrive at the output and cannot be written to the external storage due to being malformed (such as missing column values, column values of wrong type or size)."
  validation {
    condition     = contains(["drop", "stop"], lower(var.output_error_policy))
    error_message = "Valid values for output_error_policy are \"Drop\", or \"Stop\"."
  }
  default = "Drop"
}

variable "streaming_units" {
  type        = number
  description = "Specifies the number of streaming units that the streaming job uses."
  validation {
    condition     = floor(var.streaming_units) == var.streaming_units && (contains([1, 3, 6], var.streaming_units) || (var.streaming_units % 6 == 0 && var.streaming_units <= 120))
    error_message = "Valid values for output_error_policy are \"Drop\", or \"Stop\"."
  }
  default = 3
}