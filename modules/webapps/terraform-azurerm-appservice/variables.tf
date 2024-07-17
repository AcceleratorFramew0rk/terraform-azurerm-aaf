variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "app_service_plan_id" {}
variable "tags" {}
variable "client_affinity_enabled" {}
variable "client_cert_enabled" {}
variable "enabled" {}
variable "https_only" {}
variable "identity" {}
variable "key_vault_reference_identity_id" { default = null}
variable "site_config" {}
variable "app_settings" {}
variable "connection_strings" { default = null}
variable "auth_settings" { default = null}
variable "storage_account" { default = null}
variable "backup" { default = null}
variable "logs" { default = null}
variable "source_control" { default = null}
variable "custom_hostname_binding" { default = null}
