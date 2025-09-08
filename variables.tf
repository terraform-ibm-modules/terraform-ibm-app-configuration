##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

variable "region" {
  description = "The region to provision the App Configuration service, valid regions are au-syd, jp-osa, jp-tok, eu-de, eu-gb, eu-es, us-east, us-south, ca-tor, br-sao, eu-fr2, ca-mon."
  type        = string
  default     = "us-south"

  validation {
    condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "eu-es", "us-east", "us-south", "ca-tor", "br-sao", "eu-fr2", "ca-mon"], var.region)
    error_message = "Value for region must be one of the following: ${join(", ", ["jp-osa", "au-syd", "jp-tok", "eu-de", "eu-gb", "eu-es", "us-east", "us-south", "ca-tor", "br-sao", "eu-fr2", "ca-mon"])}"
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
  default     = "lite"

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

variable "config_aggregator_enterprise_account_ids_to_assign" {
  type        = list(string)
  default     = []
  description = "A list of enterprise account IDs to assign the trusted profile template to in order for the accounts to be scanned. Supports passing the string 'all' in the list to assign to all accounts. Only applies if `enable_config_aggregator` is true and a value is being passed for `config_aggregator_enterprise_id`."
  nullable    = false

  validation {
    condition     = contains(var.config_aggregator_enterprise_account_ids_to_assign, "all") ? length(var.config_aggregator_enterprise_account_ids_to_assign) == 1 : true
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

##############################################################
# KMS and EN services' integration
##############################################################

variable "enable_kms_encryption" {
  description = "Flag to enable the KMS encryption when the configured plan is 'enterprise'."
  type        = bool
  default     = false
  validation {
    condition     = !var.enable_kms_encryption || var.app_config_plan == "enterprise"
    error_message = "KMS encryption is supported only when the configured plan is 'enterprise'."
  }

  validation {
    condition     = !var.enable_kms_encryption || var.existing_kms_instance_crn != null
    error_message = "If 'enable_kms_encryption' is true, 'existing_kms_instance_crn' cannot be null."
  }

  validation {
    condition     = !var.enable_kms_encryption || var.existing_kms_instance_endpoint != null
    error_message = "If 'enable_kms_encryption' is true, 'existing_kms_instance_endpoint' cannot be null."
  }
}

variable "skip_app_config_kms_same_account_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits App configuration instances in the resource group to read the encryption key from the KMS instance in the same account. If set to false, pass in a value for the KMS instance in the `existing_kms_instance_crn` variable. If a value is specified for `ibmcloud_kms_api_key`, the policy is created in the other account."
  default     = false
}

variable "app_config_kms_integration_id" {
  type        = string
  description = "The unique ID for App Configuration and Key Management Service integration."
  default     = "ac-kms-integration"

  validation {
    condition     = length(var.app_config_kms_integration_id) <= 30
    error_message = "The length of 'app_config_kms_integration_id' must be 30 characters or less."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the existing key management service (KMS) that is used to create keys for encrypting the app config instance. If you are not using an existing KMS root key, you must specify this CRN. If you are using an existing KMS root key and auth policy is not set for app config to KMS, you must specify this CRN. This is applicable only for Enterprise plan."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}kms:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      can(regex("^crn:(.*:){3}hs-crypto:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS (Key Protect) instance CRN in not valid."
  }
}

variable "app_config_kms_key_crn" {
  description = "The CRN of the KMS key used to encrypt data from app configuration instance."
  type        = string
  default     = null
}

variable "existing_kms_instance_endpoint" {
  type        = string
  description = "The API endpoint of the existing KMS instance."
  default     = null
}

variable "enable_event_notification" {
  description = "Flag to enable the event notification when the configured plan is 'enterprise'."
  type        = bool
  default     = false
  validation {
    condition     = !var.enable_event_notification || var.app_config_plan == "enterprise"
    error_message = "Event notification integration is supported only when the configured plan is 'enterprise'."
  }

  validation {
    condition     = !var.enable_event_notification || var.existing_event_notifications_instance_crn != null
    error_message = "If 'enable_event_notification' is true, 'existing_event_notifications_instance_crn' cannot be null."
  }

  validation {
    condition     = !var.enable_event_notification || var.existing_event_notifications_instance_endpoint != null
    error_message = "If 'enable_event_notification' is true, 'existing_event_notifications_instance_endpoint' cannot be null."
  }
}

variable "app_config_event_notifications_integration_id" {
  type        = string
  description = "The unique ID for App Configuration and Event Notification Service integration."
  default     = "ac-en-integration"

  validation {
    condition     = length(var.app_config_event_notifications_integration_id) <= 30
    error_message = "The length of 'app_config_event_notifications_integration_id' must be 30 characters or less."
  }
}

variable "existing_event_notifications_instance_crn" {
  type        = string
  description = "The CRN of the existing Event Notifications instance to enable notifications for your App Configuration instance."
  default     = null

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}event-notifications:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_event_notifications_instance_crn)),
      var.existing_event_notifications_instance_crn == null,
    ])
    error_message = "The provided EN (Event Notifications) instance CRN in not valid."
  }
}

variable "existing_event_notifications_instance_endpoint" {
  type        = string
  description = "The API endpoint of the existing Event Notifications instance."
  default     = null
}

variable "app_config_event_notifications_source_name" {
  type        = string
  description = "The name by which EN source will be created in the existing Event Notification instance."
  default     = "apprapp-en-source-name"
}

variable "event_notifications_integration_description" {
  type        = string
  description = "The description of integration between Event Notification and App Configuration service."
  default     = "The app configuration integration to send notifications of events of users"
}
