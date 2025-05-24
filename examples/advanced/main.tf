########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.2.0"
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
# VPC
##############################################################################
resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

##############################################################################
# Create CBR Zone
##############################################################################

module "cbr_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.31.0"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc", # to bind a specific vpc to the zone
    value = ibm_is_vpc.example_vpc.crn,
  }]
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
  app_config_plan                        = "standardv2"
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
      description      = "${var.prefix}-APP-CONF access only from vpc"
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
}
