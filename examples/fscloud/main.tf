##############################################################################
# Resource group
##############################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.6.1"
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# Create CBR Zone for Schematics
##############################################################################

module "cbr_zone_schematics" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.37.2"
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
# Parse info from KMS key CRN
##############################################################################

module "root_key_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.9.0"
  crn     = var.root_key_crn
}

locals {
  root_key_id = module.root_key_crn_parser.resource
}

##############################################################################
# Create EN Instance
##############################################################################

module "event_notifications" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "3.0.6"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  resource_tags     = var.resource_tags
  plan              = "lite"
  service_endpoints = "public-and-private"
  region            = var.region
}

##############################################################################
# App Configuration (FSCloud profile)
##############################################################################

module "app_config" {
  source                                 = "../../modules/fscloud"
  resource_group_id                      = module.resource_group.resource_group_id
  region                                 = var.region
  app_config_name                        = "${var.prefix}-app-config"
  existing_kms_instance_crn              = var.existing_kms_instance_crn
  root_key_id                            = local.root_key_id
  kms_endpoint_url                       = var.kms_endpoint_url
  resource_tags                          = var.resource_tags
  access_tags                            = var.access_tags
  enable_config_aggregator               = true
  config_aggregator_trusted_profile_name = "${var.prefix}-config-aggregator-trusted-profile"
  app_config_collections = [
    {
      name          = "${var.prefix}-collection"
      collection_id = "${var.prefix}-collection"
      description   = "Collection for ${var.prefix}"
    }
  ]
  cbr_rules = [
    {
      description      = "${var.prefix}-app-config access only from Schematics"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            name  = "endpointType"
            value = "private"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_zone_schematics.zone_id
          }
        ]
      }]
    }
  ]
  enable_event_notifications                = true
  existing_event_notifications_instance_crn = module.event_notifications.crn
  event_notifications_endpoint_url          = module.event_notifications.event_notifications_private_endpoint
}
