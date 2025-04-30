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

##############################################################################
# Collections
##############################################################################

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
# Configuration aggregator
##############################################################################

# Create the required Trusted Profile
module "config_aggregator_trusted_profile" {
  count                       = var.enable_config_aggregator ? 1 : 0
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "2.1.1"
  trusted_profile_name        = var.config_aggregator_trusted_profile_name
  trusted_profile_description = "Trusted Profile for App Configuration instance ${ibm_resource_instance.app_config.guid} with required access for configuration aggregator"
  trusted_profile_identity = {
    identifier    = ibm_resource_instance.app_config.crn
    identity_type = "crn"
  }
  trusted_profile_policies = [
    {
      roles              = ["Viewer", "Service Configuration Reader"]
      account_management = true
      description        = "All Account Management Services"
    },
    {
      roles = ["Viewer", "Service Configuration Reader", "Reader"]
      resource_attributes = [{
        name     = "serviceType"
        value    = "service"
        operator = "stringEquals"
      }]
      description = "All Identity and Access enabled services"
    }
  ]
  trusted_profile_links = [{
    cr_type = "VSI"
    links = [{
      crn = ibm_resource_instance.app_config.crn
    }]
  }]
}

# Define an aggregation
resource "ibm_config_aggregator_settings" "config_aggregator_settings" {
  count                       = var.enable_config_aggregator ? 1 : 0
  instance_id                 = ibm_resource_instance.app_config.guid
  region                      = ibm_resource_instance.app_config.location
  resource_collection_regions = var.config_aggregator_resource_collection_regions
  resource_collection_enabled = true
  trusted_profile_id          = module.config_aggregator_trusted_profile[0].profile_id
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
