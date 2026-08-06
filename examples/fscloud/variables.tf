##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "access_tags" {
  type        = list(string)
  description = "Add access management tags to the App Configuration instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console)."
  default     = []

  validation {
    condition = alltrue([
      for tag in var.access_tags : can(regex("[\\w\\-_\\.]+:[\\w\\-_\\.]+", tag)) && length(tag) <= 128
    ])
    error_message = "Tags must match the regular expression `\"[\\w\\-_\\.]+:[\\w\\-_\\.]+\"`. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#limits)."
  }
}

variable "existing_kms_instance_crn" {
  type        = string
  description = "The CRN of the Key Protect instance. Required to use Key Protect for FSCloud compliance as App Configuration no longer supports new Hyper Protect Crypto Services (HPCS) integrations. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-relnotes#app-configuration-Mar172026)."
}

variable "root_key_crn" {
  type        = string
  description = "The CRN of a root key, existing in the KMS instance passed in var.existing_kms_instance_crn, which will be used to encrypt the data encryption keys (DEKs) which are then used to encrypt the data."
}

variable "kms_endpoint_url" {
  type        = string
  description = "The KMS endpoint URL to use when you configure KMS encryption."
}
