########################################################################################################################
# Common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"
  nullable    = false

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid value for 'provider_visibility'. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision resource in."
  default     = "Default"
  nullable    = false
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "Prefix to add to all the resources created by this solution. To not use any prefix value, you can set this value to `null` or an empty string."

  validation {
    condition = (var.prefix == null ? true :
      alltrue([
        can(regex("^[a-z]([-a-z0-9]{0,14}[a-z0-9])?$", var.prefix)),
        length(regexall("^.*--.*", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter, contain only lowercase letters, numbers, and - characters. Prefixes must end with a lowercase letter or number and be 16 or fewer characters."
  }
}

variable "region" {
  type        = string
  description = "The region to provision resources to."
  default     = "us-south"
  nullable    = false
}

########################################################################################################################
# App Config variables
########################################################################################################################


variable "app_config_name" {
  type        = string
  description = "Name for the App Configuration service instance"
  default     = "app_config"
  nullable    = false
}

variable "app_config_plan" {
  type        = string
  description = "Plan for the App Configuration service instance, valid plans are lite, standardv2, and enterprise."
  default     = "lite"
  nullable    = false
}

variable "app_config_service_endpoints" {
  type        = string
  description = "Service Endpoints for the App Configuration service instance, valid endpoints are public or public-and-private."
  default     = "public-and-private"
  nullable    = false
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

variable "app_config_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the App Config instance."
  default     = []
}

##############################################################
# Context-based restriction (CBR)
##############################################################

variable "app_config_cbr_rules" {
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
}
