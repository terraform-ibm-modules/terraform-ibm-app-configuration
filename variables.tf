##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

variable "region" {
  description = "The region to provision the App Configuration service, valid regions are au-syd, jp-osa, jp-tok, eu-de, eu-gb, eu-es, us-east, us-south, ca-tor, br-sao."
  type        = string
  default     = "us-south"

  validation {
    condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "eu-es", "us-east", "us-south", "ca-tor", "br-sao"], var.region)
    error_message = "Value for region must be one of the following: ${join(", ", ["jp-osa", "au-syd", "jp-tok", "eu-de", "eu-gb", "eu-es", "us-east", "us-south", "ca-tor", "br-sao"])}"
  }
}

########################################################################################################################
# App Config Instance Variables
########################################################################################################################

variable "app_config_name" {
  type        = string
  description = "Name for the App Configuration service instance"
}

variable "app_config_plan" {
  type        = string
  description = "Plan for the App Configuration service instance, valid plans are lite, basic, standardv2, and enterprise."
  default     = "basic"

  validation {
    condition     = contains(["lite", "standardv2", "basic", "enterprise"], var.app_config_plan)
    error_message = "Value for plan must be one of the following: \"lite\", \"basic\", \"standardv2\", or \"enterprise\"."
  }
}

variable "app_config_service_endpoints" {
  type        = string
  description = "Service Endpoints for the App Configuration service instance, valid endpoints are public or public-and-private."
  default     = "public-and-private"

  validation {
    condition     = contains(["public", "public-and-private"], var.app_config_service_endpoints)
    error_message = "Value for service endpoints must be one of the following: \"public\" or \"public-and-private\"."
  }
}

variable "app_config_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the App Config instance."
  default     = []
}

variable "app_config_collections" {
  description = "A list of collections to be added to the App Configuration instance"
  type = list(object({
    name          = string
    collection_id = string
    description   = optional(string, null)
    tags          = optional(string, null)
  }))
  default = []

  validation {
    condition = (
      var.app_config_plan != "lite" ||
      length(var.app_config_collections) <= 1
    )
    error_message = "When using the 'lite' plan, you can define at most 1 App Configuration collection."
  }
}

##############################################################
# Configuration aggregator
##############################################################

variable "enable_config_aggregator" {
  description = "Set to true to enable configuration aggregator. By setting to true a trusted profile will be created with the required access to record configuration data from all resources across regions in your account. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-configuration-aggregator)."
  type        = bool
  default     = false
  nullable    = false

  # Lite plan does not support enabling Config Aggregator as mention in doc : https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-configuration-aggregator
  validation {
    condition     = !(var.enable_config_aggregator && var.app_config_plan == "lite")
    error_message = "The configuration aggregator cannot be enabled when the app_config_plan is set to 'lite'. Please use a different plan (e.g., 'basic', 'standardv2', or 'enterprise')."
  }
}

variable "config_aggregator_trusted_profile_name" {
  description = "The name to give the trusted profile that will be created if `enable_config_aggregator` is set to `true`."
  type        = string
  default     = "config-aggregator-trusted-profile"

  validation {
    condition     = var.enable_config_aggregator ? var.config_aggregator_trusted_profile_name != null : true
    error_message = "'config_aggregator_trusted_profile_name' cannot be null if 'enable_config_aggregator' is true."
  }
}

variable "config_aggregator_resource_collection_regions" {
  type        = list(string)
  description = "From which region do you want to collect configuration data? Only applies if `enable_config_aggregator` is set to true."
  default     = ["all"]
}

variable "config_aggregator_enterprise_id" {
  type        = string
  description = "If the account is an enterprise account, this value should be set to the enterprise ID (NOTE: This is different to the account ID). "
  default     = null

  validation {
    condition     = !var.enable_config_aggregator ? var.config_aggregator_enterprise_id == null : true
    error_message = "A value can only be passed for 'config_aggregator_enterprise_id' if 'enable_config_aggregator' is true."
  }
}

variable "config_aggregator_enterprise_trusted_profile_name" {
  description = "The name to give the enterprise viewer trusted profile with that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`."
  type        = string
  default     = "config-aggregator-enterprise-trusted-profile"

  validation {
    condition     = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? var.config_aggregator_enterprise_trusted_profile_name != null : true
    error_message = "'config_aggregator_enterprise_trusted_profile_name' cannot be null if 'enable_config_aggregator' is true and a value is being passed for 'config_aggregator_enterprise_id'."
  }
}

variable "config_aggregator_enterprise_trusted_profile_template_name" {
  description = "The name to give the trusted profile template that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`."
  type        = string
  default     = "config-aggregator-trusted-profile-template"

  validation {
    condition     = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? var.config_aggregator_enterprise_trusted_profile_template_name != null : true
    error_message = "'config_aggregator_enterprise_trusted_profile_template_name' cannot be null if 'enable_config_aggregator' is true and a value is being passed for 'config_aggregator_enterprise_id'."
  }
}

variable "config_aggregator_enterprise_account_group_ids_to_assign" {
  type        = list(string)
  default     = ["all"]
  description = "A list of enterprise account group IDs to assign the trusted profile template to in order for the accounts to be scanned. Supports passing the string 'all' in the list to assign to all account groups. Only applies if `enable_config_aggregator` is true and a value is being passed for `config_aggregator_enterprise_id`."
  nullable    = false

  validation {
    condition     = contains(var.config_aggregator_enterprise_account_group_ids_to_assign, "all") ? length(var.config_aggregator_enterprise_account_group_ids_to_assign) == 1 : true
    error_message = "When specifying 'all' in the list, you cannot add any other values to the list"
  }
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    tags = optional(list(object({
      name  = string
      value = string
    })), [])
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
  }))
  description = "The list of context-based restriction rules to create."
  default     = []
  # Validation happens in the rule module
}
