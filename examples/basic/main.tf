########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.0.6"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# COS instance
########################################################################################################################

module "app_config" {
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  app_config_name   = "${var.prefix}-app-config"
  app_config_tags   = var.resource_tags

  app_config_collections = [
    {
      name          = "${var.prefix}-collection",
      collection_id = "${var.prefix}-collection"
      description   = "Collection for ${var.prefix}"
    }
  ]
}
