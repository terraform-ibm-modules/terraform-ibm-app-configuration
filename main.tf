##############################################################################
# App Config module
##############################################################################

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

##############################################################################
# Context Based Restrictions
##############################################################################
module "cbr_rule" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.28.0"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = ibm_resource_instance.app_config.guid
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "apprapp"
        operator = "stringEquals"
      }
    ],
    tags = var.cbr_rules[count.index].tags
  }]
}
