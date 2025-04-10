variable "app_config_instance_guid" {
  type        = string
  description = "GUID of the App Configuration instance"
}

variable "region" {
  type        = string
  description = "Region where the Config Aggregator will be deployed"
}

variable "enterprise_id" {
  type        = string
  description = "Enterprise ID to scope the Config Aggregator"
}

variable "trusted_profile_template_id" {
  type        = string
  description = "Trusted Profile Template ID used for additional scope"
}

variable "enterprise_trusted_profile_id" {
  type        = string
  description = "Trusted Profile ID used to authorize resource collection scoping"
}

variable "general_trusted_profile_id" {
  type        = string
  description = "Trusted Profile ID used to authorize resource collection"
}
