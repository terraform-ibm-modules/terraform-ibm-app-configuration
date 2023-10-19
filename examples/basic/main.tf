########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# App Config
########################################################################################################################

module "app_config" {
  source                       = "../.."
  resource_group_id            = module.resource_group.resource_group_id
  region                       = var.region
  app_config_name              = "${var.prefix}-app-config"
  app_config_tags              = var.resource_tags
  app_config_plan              = "lite"
  app_config_service_endpoints = "public-and-private"
}
