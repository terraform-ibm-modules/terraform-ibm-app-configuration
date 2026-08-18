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
