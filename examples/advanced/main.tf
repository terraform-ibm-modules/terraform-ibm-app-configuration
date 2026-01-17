########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone for Schematics service
##############################################################################

module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.35.10"
  name             = "${var.prefix}-schematics-zone"
  zone_description = "CBR Network zone containing Schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef",
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
}

##############################################################################
# Create KMS Instance
##############################################################################

locals {
  key_ring_name = "${var.prefix}-ring"
  key_name      = "${var.prefix}-root-key"
}

module "key_protect_all_inclusive" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.5.21"
  resource_group_id         = module.resource_group.resource_group_id
  key_protect_instance_name = "${var.prefix}-kms"
  region                    = var.region
  resource_tags             = var.resource_tags
  key_ring_endpoint_type    = "public"
  key_endpoint_type         = "public"
  keys = [
    {
      key_ring_name = local.key_ring_name
      keys = [
        {
          key_name     = local.key_name
          force_delete = true # Setting it to true for testing purpose
        }
      ]
    }
  ]
}

##############################################################################
# Create EN Instance
##############################################################################

module "event_notifications" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.10.38"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  tags              = var.resource_tags
  plan              = "lite"
  service_endpoints = "public-and-private"
  region            = var.region
}


########################################################################################################################
# App Config
########################################################################################################################

module "app_config" {
  source                                 = "../.."
  resource_group_id                      = module.resource_group.resource_group_id
  region                                 = var.region
  app_config_name                        = "${var.prefix}-app-config"
  app_config_tags                        = var.resource_tags
  enable_config_aggregator               = true # See https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-configuration-aggregator
  app_config_plan                        = "enterprise"
  config_aggregator_trusted_profile_name = "${var.prefix}-config-aggregator-trusted-profile"
  app_config_collections = [
    {
      name          = "${var.prefix}-collection",
      collection_id = "${var.prefix}-collection"
      description   = "Collection for ${var.prefix}"
    }
  ]
  cbr_rules = [
    {
      description      = "${var.prefix}-APP-CONF access only from Schematics"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      tags = [
        {
          name  = "test-name"
          value = "test-value"
        }
      ]
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone.zone_id
        }]
      }]
    }
  ]
  kms_encryption_enabled                    = true
  existing_kms_instance_crn                 = module.key_protect_all_inclusive.key_protect_crn
  root_key_id                               = module.key_protect_all_inclusive.keys["${local.key_ring_name}.${local.key_name}"].key_id
  kms_endpoint_url                          = module.key_protect_all_inclusive.kms_public_endpoint
  enable_event_notifications                = true
  existing_event_notifications_instance_crn = module.event_notifications.crn
  event_notifications_endpoint_url          = module.event_notifications.event_notifications_public_endpoint
}
