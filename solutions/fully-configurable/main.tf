locals {
  prefix    = var.prefix != null ? (trimspace(var.prefix) != "" ? "${trimspace(var.prefix)}-" : "") : ""
  crn_parts = var.existing_kms_key_crn != null ? split(":", var.existing_kms_key_crn) : null

  kms_instance_crn = var.existing_kms_instance_crn != null ? var.existing_kms_instance_crn : var.existing_kms_key_crn != null ? "${join(":", slice(local.crn_parts, 0, length(local.crn_parts) - 2))}::" : null
  kms_key_crn      = var.enable_kms_encryption ? (var.existing_kms_key_crn != null ? var.existing_kms_key_crn : module.kms[0].keys[format("%s.%s", local.kms_key_ring_name, local.kms_key_name)].crn) : null

  kms_region        = var.enable_kms_encryption && (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null) ? module.existing_kms_crn_parser[0].region : null
  kms_service_name  = var.enable_kms_encryption && (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null) ? module.existing_kms_crn_parser[0].service_name : null
  kms_instance_guid = var.enable_kms_encryption && (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null) ? module.existing_kms_crn_parser[0].service_instance : null
  kms_account_id    = var.enable_kms_encryption && (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null) ? module.existing_kms_crn_parser[0].account_id : null

  kms_key_ring_name = var.app_config_key_ring_name != null ? "${local.prefix}${var.app_config_key_ring_name}" : null
  kms_key_name      = var.app_config_key_name != null ? "${local.prefix}${var.app_config_key_name}" : null

  create_kms_cross_account_auth_policy = var.skip_app_config_kms_iam_auth_policy && var.ibmcloud_kms_api_key != null

  en_region = var.enable_event_notification && var.existing_event_notifications_instance_crn != null ? module.existing_en_crn_parser[0].region : null

  kms_endpoint = var.enable_kms_encryption && (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null) ? (
    local.kms_service_name == "hs-crypto" ? (
      var.kms_endpoint_type == "private" ? "https://${local.kms_instance_guid}.api.private.${local.kms_region}.hs-crypto.appdomain.cloud" : "https://${local.kms_instance_guid}.api.${local.kms_region}.hs-crypto.appdomain.cloud"
      ) : (
      var.kms_endpoint_type == "private" ? "https://${local.kms_region}.${local.kms_service_name}.cloud.ibm.com" : "https://${local.kms_region}.${local.kms_service_name}.cloud.ibm.com"
    )
  ) : null

  en_endpoint = var.enable_event_notification && var.existing_event_notifications_instance_crn != null ? var.event_notifications_endpoint_type == "private" ? "https://private.${local.en_region}.event-notifications.cloud.ibm.com" : "https://${local.en_region}.event-notifications.cloud.ibm.com" : null

  kms_key_id = var.enable_kms_encryption && var.existing_kms_key_crn != null ? module.kms_key_crn_parser[0].resource : (var.existing_kms_instance_crn != null && var.enable_kms_encryption ? module.kms[0].keys[format("%s.%s", local.kms_key_ring_name, local.kms_key_name)].key_id : null)
}

data "ibm_iam_account_settings" "iam_account_settings" {
  count = local.create_kms_cross_account_auth_policy ? 1 : 0
}


#######################################################################################################################
# Resource Group
#######################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.3.0"
  existing_resource_group_name = var.existing_resource_group_name
}

#######################################################################################################################
# KMS Instance Parser
#######################################################################################################################

# parse KMS details from the existing KMS instance CRN
module "existing_kms_crn_parser" {
  count   = var.enable_kms_encryption && (var.existing_kms_instance_crn != null || var.existing_kms_key_crn != null) ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = local.kms_instance_crn
}

module "kms_key_crn_parser" {
  count   = var.enable_kms_encryption && var.existing_kms_key_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = local.kms_key_crn
}

#######################################################################################################################
# EN Parser
#######################################################################################################################

# parse EN details from the existing EN instance CRN
module "existing_en_crn_parser" {
  count   = var.enable_event_notification && var.existing_event_notifications_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_event_notifications_instance_crn
}

# Create auth policy (scoped to exact KMS key)
resource "ibm_iam_authorization_policy" "kms_cross_account_policy" {
  count                    = var.enable_kms_encryption && local.create_kms_cross_account_auth_policy ? 1 : 0
  provider                 = ibm.kms
  source_service_account   = data.ibm_iam_account_settings.iam_account_settings[0].account_id
  source_service_name      = "apprapp"
  source_resource_group_id = module.resource_group.resource_group_id
  roles                    = ["Reader"]
  description              = "Allow all App Configuration instances in the resource group ${local.kms_account_id} to read the ${local.kms_service_name} key ${local.kms_key_id} from the instance GUID ${local.kms_instance_guid}"
  resource_attributes {
    name     = "serviceName"
    operator = "stringEquals"
    value    = local.kms_service_name
  }
  resource_attributes {
    name     = "accountId"
    operator = "stringEquals"
    value    = local.kms_account_id
  }
  resource_attributes {
    name     = "serviceInstance"
    operator = "stringEquals"
    value    = local.kms_instance_guid
  }
  resource_attributes {
    name     = "resourceType"
    operator = "stringEquals"
    value    = "key"
  }
  resource_attributes {
    name     = "resource"
    operator = "stringEquals"
    value    = local.kms_key_id
  }
  # Scope of policy now includes the key, so ensure to create new policy before
  # destroying old one to prevent any disruption to every day services.
  lifecycle {
    create_before_destroy = true
  }
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_kms_cross_account_authorization_policy" {
  count           = var.enable_kms_encryption && local.create_kms_cross_account_auth_policy ? 1 : 0
  depends_on      = [ibm_iam_authorization_policy.kms_cross_account_policy]
  create_duration = "30s"
}

#######################################################################################################################
# KMS Key
#######################################################################################################################

module "kms" {
  count   = var.enable_kms_encryption && var.existing_kms_instance_crn != null && var.existing_kms_key_crn == null ? 1 : 0 # no need to create any KMS resources if passing an existing key
  source  = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version = "5.1.22"
  providers = {
    ibm = ibm.kms
  }
  create_key_protect_instance = false
  region                      = local.kms_region
  existing_kms_instance_crn   = var.existing_kms_instance_crn
  key_ring_endpoint_type      = var.kms_endpoint_type
  key_endpoint_type           = var.kms_endpoint_type
  keys = [
    {
      key_ring_name         = local.kms_key_ring_name
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = local.kms_key_name
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}

########################################################################################################################
# App Config
########################################################################################################################
module "app_config" {
  depends_on                                                 = [time_sleep.wait_for_kms_cross_account_authorization_policy]
  source                                                     = "../.."
  resource_group_id                                          = module.resource_group.resource_group_id
  region                                                     = var.region
  app_config_name                                            = "${local.prefix}${var.app_config_name}"
  app_config_plan                                            = var.app_config_plan
  app_config_service_endpoints                               = var.app_config_service_endpoints
  app_config_tags                                            = var.app_config_tags
  app_config_collections                                     = var.app_config_collections
  enable_config_aggregator                                   = var.enable_config_aggregator
  config_aggregator_trusted_profile_name                     = "${local.prefix}${var.config_aggregator_trusted_profile_name}"
  config_aggregator_resource_collection_regions              = var.config_aggregator_resource_collection_regions
  config_aggregator_enterprise_id                            = var.config_aggregator_enterprise_id
  config_aggregator_enterprise_trusted_profile_name          = "${local.prefix}${var.config_aggregator_enterprise_trusted_profile_name}"
  config_aggregator_enterprise_trusted_profile_template_name = "${local.prefix}${var.config_aggregator_enterprise_trusted_profile_template_name}"
  config_aggregator_enterprise_account_group_ids_to_assign   = var.config_aggregator_enterprise_account_group_ids_to_assign
  config_aggregator_enterprise_account_ids_to_assign         = var.config_aggregator_enterprise_account_ids_to_assign
  cbr_rules                                                  = var.cbr_rules
  skip_app_config_kms_same_account_auth_policy               = var.skip_app_config_kms_iam_auth_policy
  enable_kms_encryption                                      = var.enable_kms_encryption
  app_config_kms_integration_id                              = "${local.prefix}${var.app_config_kms_integration_id}"
  existing_kms_instance_crn                                  = local.kms_instance_crn
  existing_kms_instance_endpoint                             = local.kms_endpoint
  app_config_kms_key_crn                                     = local.kms_key_crn
  enable_event_notification                                  = var.enable_event_notification
  app_config_event_notifications_integration_id              = "${local.prefix}${var.app_config_event_notifications_integration_id}"
  existing_event_notifications_instance_crn                  = var.existing_event_notifications_instance_crn
  existing_event_notifications_instance_endpoint             = local.en_endpoint
  app_config_event_notifications_source_name                 = "${local.prefix}${var.app_config_event_notifications_source_name}"
  event_notifications_integration_description                = var.event_notifications_integration_description
}
