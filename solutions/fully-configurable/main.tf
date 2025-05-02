locals {
  prefix = var.prefix != null ? (trimspace(var.prefix) != "" ? "${trimspace(var.prefix)}-" : "") : ""
}

#######################################################################################################################
# Resource Group
#######################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# App Config
########################################################################################################################
module "app_config" {
  source                       = "../.."
  resource_group_id            = module.resource_group.resource_group_id
  region                       = var.region
  app_config_name              = "${local.prefix}${var.app_config_name}"
  app_config_plan              = var.app_config_plan
  app_config_service_endpoints = var.app_config_service_endpoints
  app_config_tags              = var.app_config_tags
  app_config_collections       = var.app_config_collections
  cbr_rules                    = var.app_config_cbr_rules
}
