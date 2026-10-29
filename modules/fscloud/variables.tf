##############################################################################
# FSCloud Module Variables
##############################################################################

##############################################################################
# Common variables
##############################################################################

variable "resource_group_id" {
  type        = string
  description = "The resource group ID where resources will be provisioned."
}

variable "region" {
  description = "The region to provision the App Configuration service."
  type        = string
  default     = "us-south"
  nullable    = false
}

##############################################################################
# App Configuration Instance Variables
##############################################################################

variable "app_config_name" {
  type        = string
  description = "Name for the App Configuration service instance"
}

variable "resource_tags" {
  type        = list(string)
  description = "Add user resource tags to the App Configuration instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types)."
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Add access management tags to the App Configuration instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
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

##############################################################################
# Configuration Aggregator
##############################################################################

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
}

variable "config_aggregator_enterprise_trusted_profile_name" {
  description = "The name to give the enterprise viewer trusted profile with that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`."
  type        = string
  default     = "config-aggregator-enterprise-trusted-profile"
}

variable "config_aggregator_enterprise_trusted_profile_template_name" {
  description = "The name to give the trusted profile template that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`."
  type        = string
  default     = "config-aggregator-trusted-profile-template"
}

variable "config_aggregator_enterprise_account_group_ids_to_assign" {
  type        = list(string)
  default     = ["all"]
  description = "A list of enterprise account group IDs to assign the trusted profile template to in order for the accounts to be scanned. Supports passing the string 'all' in the list to assign to all account groups. Only applies if `enable_config_aggregator` is true and a value is being passed for `config_aggregator_enterprise_id`."
  nullable    = false
}

variable "config_aggregator_enterprise_account_ids_to_assign" {
  type        = list(string)
  default     = []
  description = "A list of enterprise account IDs to assign the trusted profile template to in order for the accounts to be scanned. Supports passing the string 'all' in the list to assign to all accounts. Only applies if `enable_config_aggregator` is true and a value is being passed for `config_aggregator_enterprise_id`."
  nullable    = false
}

##############################################################################
# KMS Encryption (REQUIRED FOR FSCLOUD)
##############################################################################

variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of the Key Protect instance. Required to use Key Protect for FSCloud compliance as App Configuration no longer supports new Hyper Protect Crypto Services (HPCS) integrations. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-relnotes#app-configuration-Mar172026)."
}

variable "root_key_id" {
  type        = string
  description = "The key ID of a root key, existing in the key management service instance passed in `var.existing_kms_instance_crn`, which is used to encrypt the data encryption keys."
}

variable "kms_endpoint_url" {
  type        = string
  description = "The KMS endpoint URL to use when you configure KMS encryption."
}

variable "skip_app_config_kms_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to read the encryption key from the KMS instance in the same account."
  default     = false
}

##############################################################################
# Context-based Restriction (CBR)
##############################################################################

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
      })))
    }))
    enforcement_mode = string
  }))
  description = "The list of context-based restrictions rules to create."
  default     = []
}

##############################################################################
# Event Notifications
##############################################################################

variable "enable_event_notifications" {
  type        = bool
  description = "Flag to enable the event notification when the configured plan is 'enterprise'."
  default     = false
}

variable "existing_event_notifications_instance_crn" {
  type        = string
  description = "The CRN of the existing Event Notifications instance to enable notifications for your App Configuration instance. It is required if `enable_event_notifications` is set to true"
  default     = null
}

variable "event_notifications_endpoint_url" {
  type        = string
  description = "The URL of the Event Notifications service endpoint to use for notifying configuration changes."
  default     = null
}

variable "event_notifications_integration_description" {
  type        = string
  description = "The description of integration between Event Notification and App Configuration service."
  default     = "The App Configuration integration to send notifications of events of users"
}

variable "app_config_event_notifications_source_name" {
  type        = string
  description = "The name by which Event Notifications source will be created in the existing Event Notification instance."
  default     = "app-config-en-source-name"
}

variable "skip_app_config_event_notifications_auth_policy" {
  type        = bool
  description = "Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to integrate with Event Notification in the same account."
  default     = false
}
