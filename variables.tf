##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

variable "region" {
  description = "The region to provision the App Configuration service, valid regions are us-south, us-east, eu-gb, and au-syd."
  type        = string
  default     = "us-south"

  validation {
    condition     = contains(["us-east", "us-south", "eu-gb", "au-syd"], var.region)
    error_message = "Value for region must be one of the following: ${join(", ", ["us-east", "us-south", "eu-gb", "au-syd"])}"
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
  description = "Plan for the App Configuration service instance, valid plans are lite, standardv2, and enterprise."
  default     = "lite"

  validation {
    condition     = contains(["lite", "standardv2", "enterprise"], var.app_config_plan)
    error_message = "Value for plan must be one of the following: \"lite\", \"standardv2\", or \"enterprise\"."
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
}

##############################################################
# Configuration aggregator
##############################################################

variable "enable_config_aggregator" {
  description = "Set to true to enable configuration aggregator. By setting to true a trusted profile will be created with the required access to record configuration data from all resources across regions in your account. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-configuration-aggregator)."
  type        = bool
  default     = false
  nullable    = false
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
