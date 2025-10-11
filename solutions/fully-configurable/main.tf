locals {
  prefix = var.prefix != null ? (trimspace(var.prefix) != "" ? "${trimspace(var.prefix)}-" : "") : ""

  existing_kms_instance_crn = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? var.existing_kms_instance_crn : "crn:v1:bluemix:${module.existing_kms_key_crn_parser[0].ctype}:${module.existing_kms_key_crn_parser[0].service_name}:${module.existing_kms_key_crn_parser[0].region}:${module.existing_kms_key_crn_parser[0].scope}:${module.existing_kms_key_crn_parser[0].service_instance}::" : null
  kms_region                = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].region : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].region : null : null
  kms_service_name          = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].service_name : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].service_name : null : null
  kms_instance_guid         = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].service_instance : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].service_instance : null : null
  kms_account_id            = var.kms_encryption_enabled ? var.existing_kms_instance_crn != null ? module.existing_kms_crn_parser[0].account_id : var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].account_id : null : null
  kms_key_id                = var.kms_encryption_enabled ? var.existing_kms_key_crn != null ? module.existing_kms_key_crn_parser[0].resource : var.existing_kms_instance_crn != null ? module.kms[0].keys[format("%s.%s", local.kms_key_ring_name, local.kms_key_name)].key_id : null : null

  kms_key_ring_name = var.app_config_key_ring_name != null ? "${local.prefix}${var.app_config_key_ring_name}" : null
  kms_key_name      = var.app_config_key_name != null ? "${local.prefix}${var.app_config_key_name}" : null

  create_kms_cross_account_auth_policy = var.skip_app_config_kms_auth_policy && var.ibmcloud_kms_api_key != null

  existing_en_guid = var.enable_event_notifications ? module.existing_en_crn_parser[0].service_instance : null
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
  count   = var.kms_encryption_enabled && var.existing_kms_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_kms_instance_crn
}

module "existing_kms_key_crn_parser" {
  count   = var.kms_encryption_enabled && var.existing_kms_key_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_kms_key_crn
}

#######################################################################################################################
# EN Parser
#######################################################################################################################

# parse EN details from the existing EN instance CRN
module "existing_en_crn_parser" {
  count   = var.enable_event_notifications && var.existing_event_notifications_instance_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_event_notifications_instance_crn
}

# Create auth policy (scoped to exact KMS key)
resource "ibm_iam_authorization_policy" "kms_cross_account_policy" {
  count                    = var.kms_encryption_enabled && local.create_kms_cross_account_auth_policy ? 1 : 0
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
  count           = var.kms_encryption_enabled && local.create_kms_cross_account_auth_policy ? 1 : 0
  depends_on      = [ibm_iam_authorization_policy.kms_cross_account_policy]
  create_duration = "30s"
}

#######################################################################################################################
# KMS Key
#######################################################################################################################

module "kms" {
  count   = var.kms_encryption_enabled && var.existing_kms_key_crn == null ? 1 : 0 # no need to create any KMS resources if passing an existing key
  source  = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version = "5.3.4"
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
  kms_encryption_enabled                                     = var.kms_encryption_enabled
  skip_app_config_kms_auth_policy                            = var.skip_app_config_kms_auth_policy
  existing_kms_instance_crn                                  = local.existing_kms_instance_crn
  kms_endpoint_url                                           = var.kms_endpoint_url
  root_key_id                                                = local.kms_key_id
  enable_event_notifications                                 = var.enable_event_notifications
  skip_app_config_event_notifications_auth_policy            = var.skip_app_config_event_notifications_auth_policy
  existing_event_notifications_instance_crn                  = var.existing_event_notifications_instance_crn
  event_notifications_endpoint_url                           = var.event_notifications_endpoint_url
  app_config_event_notifications_source_name                 = "${local.prefix}${var.app_config_event_notifications_source_name}"
  event_notifications_integration_description                = var.enable_event_notifications ? "The App Configuration integration to send notifications of events to users from the Event Notifications instance GUID ${local.existing_en_guid}" : null
}

#######################################################################################################################
# App Configuration Event Notifications Configuration
#######################################################################################################################

data "ibm_en_destinations" "en_destinations" {
  count         = var.enable_event_notifications ? 1 : 0
  instance_guid = local.existing_en_guid
}

resource "ibm_en_topic" "en_topic" {
  count         = var.enable_event_notifications ? 1 : 0
  depends_on    = [module.app_config]
  instance_guid = local.existing_en_guid
  name          = "Topic for App Configuration instance ${module.app_config.app_config_guid}"
  description   = "Topic for App Configuration events routing"
  sources {
    id = module.app_config.app_config_crn
    rules {
      enabled           = true
      event_type_filter = "$.*"
    }
  }
}

resource "ibm_en_subscription_email" "email_subscription" {
  count          = var.enable_event_notifications && length(var.event_notifications_email_list) > 0 ? 1 : 0
  instance_guid  = local.existing_en_guid
  name           = "Email for App Configuration Subscription"
  description    = "Subscription for App Configuration Events"
  destination_id = [for s in toset(data.ibm_en_destinations.en_destinations[count.index].destinations) : s.id if s.type == "smtp_ibm"][0]
  topic_id       = ibm_en_topic.en_topic[count.index].topic_id
  attributes {
    add_notification_payload = true
    reply_to_mail            = var.event_notifications_reply_to_email
    reply_to_name            = "App Configuration Event Notifications Bot"
    from_name                = var.event_notifications_from_email
    invited                  = var.event_notifications_email_list
  }
}
