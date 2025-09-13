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

variable "kms_encryption_enabled" {
  description = "Flag to enable the KMS encryption when the configured plan is 'enterprise'."
  type        = bool
  default     = false
  validation {
    condition     = !var.kms_encryption_enabled || var.app_config_plan == "enterprise"
    error_message = "KMS encryption is supported only when the configured plan is 'enterprise'."
  }

  validation {
    condition     = !var.kms_encryption_enabled || var.existing_kms_instance_crn != null
    error_message = "If 'kms_encryption_enabled' is true, 'existing_kms_instance_crn' cannot be null."
  }

  validation {
    condition     = !var.kms_encryption_enabled || var.root_key_id != null
    error_message = "If 'kms_encryption_enabled' is true, 'root_key_id' cannot be null."
  }

  validation {
    condition     = !var.kms_encryption_enabled || var.kms_endpoint_url != null
    error_message = "If 'kms_encryption_enabled' is true, 'kms_endpoint_url' cannot be null."
  }

  validation {
    condition = var.kms_encryption_enabled ? anytrue([
      split(":", var.existing_kms_instance_crn)[5] == split(".", split("//", var.kms_endpoint_url)[1])[0],
      split(":", var.existing_kms_instance_crn)[5] == split(".", split("//", var.kms_endpoint_url)[1])[1],
      split(":", var.existing_kms_instance_crn)[5] == split(".", var.kms_endpoint_url)[3],
      split(":", var.existing_kms_instance_crn)[5] == split(".", var.kms_endpoint_url)[2],
    ]) : true
    error_message = "The region specified in the `existing_kms_instance_crn` does not match the region in the `kms_endpoint_url`."
  }
}

variable "skip_app_config_kms_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to read the encryption key from the KMS instance in the same account."
  default     = false
}

variable "existing_kms_instance_crn" {
  type        = string
  default     = null
  description = "The CRN of the Hyper Protect Crypto Services or Key Protect instance. Required only if `var.kms_encryption_enabled` is set to `true`."

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}kms:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      can(regex("^crn:(.*:){3}hs-crypto:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_kms_instance_crn)),
      var.existing_kms_instance_crn == null,
    ])
    error_message = "The provided KMS (Key Protect) instance CRN in not valid."
  }
}

variable "root_key_id" {
  type        = string
  description = "The key ID of a root key, existing in the key management service instance passed in `var.existing_kms_instance_crn`, which is used to encrypt the data encryption keys which are then used to encrypt the data. Required only if `var.kms_encryption_enabled` is set to `true`."
  default     = null
}

variable "kms_endpoint_url" {
  description = "The URL of the key management service endpoint to use for key encryption. For more information on the endpoint URL format for Hyper Protect Crypto Services, go to [Instance-based endpoints](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-regions#new-service-endpoints). For more information on the endpoint URL format for Key Protect, go to [Service endpoints](https://cloud.ibm.com/docs/key-protect?topic=key-protect-regions#service-endpoints). It is required if `kms_encryption_enabled` is set to true."
  type        = string
  default     = null
}

variable "enable_event_notifications" {
  description = "Flag to enable the event notification when the configured plan is 'enterprise'."
  type        = bool
  default     = false
  validation {
    condition     = !var.enable_event_notifications || var.app_config_plan == "enterprise"
    error_message = "Event notification integration is supported only when the configured plan is 'enterprise'."
  }

  validation {
    condition     = !var.enable_event_notifications || var.existing_event_notifications_instance_crn != null
    error_message = "If 'enable_event_notifications' is true, 'existing_event_notifications_instance_crn' cannot be null."
  }

  validation {
    condition     = !var.enable_event_notifications || var.event_notifications_endpoint_url != null
    error_message = "If 'enable_event_notifications' is true, 'event_notifications_endpoint_url' cannot be null."
  }

  validation {
    condition     = var.enable_event_notifications == false ? (var.existing_event_notifications_instance_crn == null && var.event_notifications_endpoint_url == null) : true
    error_message = "If 'enable_event_notifications' is set to false. You should not pass values for 'existing_event_notifications_instance_crn' or 'event_notifications_endpoint_url'."
  }

  validation {
    condition = var.enable_event_notifications ? anytrue([
      split(":", var.existing_event_notifications_instance_crn)[5] == split(".", split("//", var.event_notifications_endpoint_url)[1])[0],
      split(":", var.existing_event_notifications_instance_crn)[5] == split(".", split("//", var.event_notifications_endpoint_url)[1])[1],
    ]) : true
    error_message = "The region specified in the `existing_event_notifications_instance_crn` does not match the region in the `event_notifications_endpoint_url`."
  }
}

variable "skip_app_config_event_notifications_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to integrate with Event Notification in the same account."
  default     = false
}

variable "existing_event_notifications_instance_crn" {
  type        = string
  description = "The CRN of the existing Event Notifications instance to enable notifications for your App Configuration instance. It is required if `enable_event_notifications` is set to true"
  default     = null

  validation {
    condition = anytrue([
      can(regex("^crn:(.*:){3}event-notifications:(.*:){2}[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}::$", var.existing_event_notifications_instance_crn)),
      var.existing_event_notifications_instance_crn == null,
    ])
    error_message = "The provided Event Notifications instance CRN in not valid."
  }
}

variable "event_notifications_endpoint_url" {
  type        = string
  description = "The URL of the Event Notifications service endpoint to use for notifying configuration changes. For more information on the endpoint URL for Event Notifications, go to [Service endpoints](https://cloud.ibm.com/docs/event-notifications?topic=event-notifications-en-regions-endpoints#en-service-endpoints). It is required if `enable_event_notifications` is set to true."
  default     = null
}

variable "app_config_event_notifications_source_name" {
  type        = string
  description = "The name by which Event Notifications source will be created in the existing Event Notification instance."
  default     = "app-config-en-source-name"
}

variable "event_notifications_integration_description" {
  type        = string
  description = "The description of integration between Event Notification and App Configuration service."
  default     = "The App Configuration integration to send notifications of events of users"
}
