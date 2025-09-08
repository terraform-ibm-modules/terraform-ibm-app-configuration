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
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
  default     = null
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-us-south. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-) and must not exceed 16 characters in length: [a-z0-9-]{0,14}
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]{0,14}[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }
}

variable "region" {
  type        = string
  description = "The region to provision all resources in. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/region) about how to select different regions for different services."
  default     = "us-south"
  nullable    = false
}

########################################################################################################################
# App Config variables
########################################################################################################################


variable "app_config_name" {
  type        = string
  description = "Name for the App Configuration service instance."
  default     = "app-config"
  nullable    = false
}

variable "app_config_plan" {
  type        = string
  description = "Plan for the App Configuration service instance."
  default     = "standardv2"
  nullable    = false
}

variable "app_config_service_endpoints" {
  type        = string
  description = "Service Endpoints for the App Configuration service instance, valid endpoints are public or public-and-private."
  default     = "public-and-private"
  nullable    = false
}

variable "app_config_collections" {
  description = "(Optional, list) A list of collections to be added to the App Configuration instance. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/solutions/fully-configurable/DA-collections.md)."
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

variable "app_config_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to the App Config instance."
  default     = []
}

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
  description = "The name to give the trusted profile that will be created if `enable_config_aggregator` is set to `true`. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
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
  description = "The name to give the enterprise viewer trusted profile with that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
  type        = string
  default     = "config-aggregator-enterprise-trusted-profile"

  validation {
    condition     = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? var.config_aggregator_enterprise_trusted_profile_name != null : true
    error_message = "'config_aggregator_enterprise_trusted_profile_name' cannot be null if 'enable_config_aggregator' is true and a value is being passed for 'config_aggregator_enterprise_id'."
  }
}

variable "config_aggregator_enterprise_trusted_profile_template_name" {
  description = "The name to give the trusted profile template that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format."
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
  description = "(Optional, list) A list of context-based restrictions rules to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/solutions/fully-configurable/DA-cbr_rules.md)."
  default     = []
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
    condition     = !var.enable_kms_encryption || (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null)
    error_message = "If 'enable_kms_encryption' is true, either 'existing_kms_instance_crn' or 'existing_kms_key_crn' must be provided."
  }
}

variable "skip_app_config_kms_iam_auth_policy" {
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

variable "existing_kms_key_crn" {
  type        = string
  default     = null
  description = "The CRN of an existing key management service (Key Protect) key to use to encrypt the app config instance that this solution creates. To create a key ring and key, pass a value for the `existing_kms_instance_crn` input variable. This is applicable only for Enterprise plan. Either `existing_kms_key_crn` or `existing_kms_instance_crn` needs to be provided."
}

variable "kms_endpoint_type" {
  type        = string
  description = "The type of endpoint to use for communicating with the Key Protect instance. Possible values: `public`, `private`. Applies only if `existing_kms_key_crn` is specified. This is applicable only for Enterprise plan."
  default     = "private"
  validation {
    condition     = can(regex("public|private", var.kms_endpoint_type))
    error_message = "Valid values for the `kms_endpoint_type` are `public` or `private`."
  }
}

variable "app_config_key_ring_name" {
  type        = string
  default     = "apprapp-key-ring"
  description = "The name of the key ring to create for the app configuration instance. If an existing key is used, this variable is not required. If the prefix input variable is passed, the name of the key ring is prefixed to the value in the `<prefix>-value` format. This is applicable only for Enterprise plan."
}

variable "app_config_key_name" {
  type        = string
  default     = "apprapp-key"
  description = "The name of the key to create for the app configuration instance. If an existing key is used, this variable is not required. If the prefix input variable is passed, the name of the key is prefixed to the value in the `<prefix>-value` format. This is applicable only for Enterprise plan."
}

variable "ibmcloud_kms_api_key" {
  type        = string
  description = "The IBM Cloud API key that can create a root key and key ring in the key management service (KMS) instance. If not specified, the 'ibmcloud_api_key' variable is used. Specify this key if the instance in `existing_kms_instance_crn` is in an account that's different from the App Configuration instance. Leave this input empty if the same account owns both instances."
  sensitive   = true
  default     = null

  validation {
    condition     = !var.skip_app_config_kms_iam_auth_policy || var.ibmcloud_kms_api_key != null
    error_message = "The 'ibmcloud_kms_api_key' variable must not be null when 'skip_app_config_kms_iam_auth_policy' is set to true."
  }
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

variable "event_notifications_endpoint_type" {
  type        = string
  description = "The type of endpoint to use for communicating with the Event Notification instance. Possible values: `public`, `private`. Applies only if `existing_event_notifications_instance_crn` is specified. This is applicable only for Enterprise plan."
  default     = "private"
  validation {
    condition     = contains(["public", "private", "public-and-private"], var.event_notifications_endpoint_type)
    error_message = "The specified endpoint is not supported. The following endpoint options are supported: `public`, `private`, `public-and-private`."
  }
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
