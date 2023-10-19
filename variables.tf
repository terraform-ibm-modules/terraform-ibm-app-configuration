##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

variable "region" {
  description = "The region to provision the resources."
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
  description = "Plan for the App Configuration service instance"
  default     = "lite"

  validation {
    condition     = contains(["lite", "standardv2", "enterprise"], var.app_config_plan)
    error_message = "Value for plan must be one of the following: \"lite\", \"standardv2\", or \"enterprise\"."
  }
}

variable "app_config_service_endpoints" {
  type        = string
  description = "Service Endpoints for the App Configuration service instance"
  default     = "public"

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
