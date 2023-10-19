##############################################################################
# App Config module
##############################################################################

locals {
  # tflint-ignore: terraform_unused_declarations
  validate_endpoint = var.app_config_service_endpoints == "public-and-private" && var.app_config_plan != "enterprise" ? tobool("The endpoint type 'public-and-private' is only available if the value for var.app_config_plan is 'enterprise'.") : true
}

resource "ibm_resource_instance" "app_config" {
  resource_group_id = var.resource_group_id
  location          = var.region
  name              = var.app_config_name
  service           = "apprapp"
  plan              = var.app_config_plan
  service_endpoints = var.app_config_service_endpoints
  tags              = var.app_config_tags
}

locals {
  collections_map = {
    for obj in var.app_config_collections :
    (obj.name) => obj
  }
}

resource "ibm_app_config_collection" "collections" {
  for_each      = local.collections_map
  guid          = ibm_resource_instance.app_config.guid
  name          = each.value.name
  collection_id = each.value.collection_id
  description   = each.value.description
  tags          = each.value.tags
}
