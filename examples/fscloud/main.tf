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
  version          = "1.36.7"
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

locals {
  root_key_id = element(split(":", var.root_key_crn), length(split(":", var.root_key_crn)) - 1)
}

##############################################################################
# App Configuration (FSCloud profile)
##############################################################################

module "app_config" {
  source                    = "../../modules/fscloud"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  app_config_name           = "${var.prefix}-app-config"
  existing_kms_instance_crn = var.existing_kms_instance_crn
  root_key_id               = local.root_key_id
  kms_endpoint_url          = var.kms_endpoint_url
  resource_tags             = var.resource_tags
  access_tags               = var.access_tags
  cbr_rules = [
    {
      description      = "${var.prefix}-app-config access only from Schematics"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            name  = "networkZoneId"
            value = module.cbr_zone_schematics.zone_id
          }
        ]
      }]
    }
  ]
}
