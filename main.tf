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
  version                     = "3.1.1"
  trusted_profile_name        = var.config_aggregator_trusted_profile_name
  trusted_profile_description = "Trusted Profile for App Configuration instance ${ibm_resource_instance.app_config.guid} with required access for configuration aggregator"
  trusted_profile_identity = {
    identifier    = ibm_resource_instance.app_config.crn
    identity_type = "crn"
  }
  # unique_identifier should not be updated as it will create a breaking change for trusted profile. For more information please check https://github.com/terraform-ibm-modules/terraform-ibm-trusted-profile/releases/tag/v3.0.0 .
  trusted_profile_policies = [
    {
      unique_identifier  = "config-aggregator-trusted-profile-0"
      roles              = ["Viewer", "Service Configuration Reader"]
      account_management = true
      description        = "All Account Management Services"
    },
    {
      unique_identifier = "config-aggregator-trusted-profile-1"
      roles             = ["Viewer", "Service Configuration Reader", "Reader"]
      resource_attributes = [{
        name     = "serviceType"
        value    = "service"
        operator = "stringEquals"
      }]
      description = "All Identity and Access enabled services"
    }
  ]
  trusted_profile_links = [{
    unique_identifier = "config-aggregator-trusted-profile-0"
    cr_type           = "VSI"
    links = [{
      crn = ibm_resource_instance.app_config.crn
    }]
  }]
}

# If enterprise account, create custom role "Template Assignment Reader"
# This role is used in the trusted profile to grant permission to read IAM template assignments.
# It is required by the App Config enterprise-level trusted profile to manage IAM templates."
locals {
  custom_role = "Template Assignment Reader"
}
resource "ibm_iam_custom_role" "template_assignment_reader" {
  count        = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? 1 : 0
  name         = "TemplateAssignmentReader"
  service      = "iam-identity"
  display_name = local.custom_role
  description  = "Custom role to allow reading IAM template assignments"
  actions      = ["iam-identity.profile-assignment.read"]
}

# If enterprise account, create trusted profile for App Config enterprise-level permissions
module "config_aggregator_trusted_profile_enterprise" {
  count                       = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? 1 : 0
  source                      = "terraform-ibm-modules/trusted-profile/ibm"
  version                     = "3.1.1"
  trusted_profile_name        = var.config_aggregator_enterprise_trusted_profile_name
  trusted_profile_description = "Trusted Profile for App Configuration instance ${ibm_resource_instance.app_config.guid} with required access for configuration aggregator for enterprise accounts"

  trusted_profile_identity = {
    identifier    = ibm_resource_instance.app_config.crn
    identity_type = "crn"
  }

  trusted_profile_policies = [
    {
      unique_identifier = "config-aggregator-trusted-profile-0"
      roles             = ["Viewer", local.custom_role]
      resource_attributes = [{
        name     = "service_group_id"
        value    = "IAM"
        operator = "stringEquals"
      }]
      description = "IAM access with custom role"
    },
    {
      unique_identifier = "config-aggregator-trusted-profile-1"
      roles             = ["Viewer"]
      resources = [{
        service = "enterprise"
      }]
      description = "Enterprise viewer and template reader access"
    }
  ]

  trusted_profile_links = [{
    unique_identifier = "config-aggregator-trusted-profile-0"
    cr_type           = "VSI"
    links = [{
      crn = ibm_resource_instance.app_config.crn
    }]
  }]
}

# If enterprise account, create trusted profile template
module "config_aggregator_trusted_profile_template" {
  count                = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? 1 : 0
  source               = "terraform-ibm-modules/trusted-profile/ibm//modules/trusted-profile-template"
  version              = "3.1.1"
  template_name        = var.config_aggregator_enterprise_trusted_profile_template_name
  template_description = "Trusted Profile template for App Configuration instance ${ibm_resource_instance.app_config.guid} with required access for configuration aggregator"
  profile_name         = var.config_aggregator_trusted_profile_name
  profile_description  = "Trusted Profile for App Configuration instance ${ibm_resource_instance.app_config.guid} with required access for configuration aggregator"
  identities = [
    {
      type       = "crn"
      iam_id     = "crn-${ibm_resource_instance.app_config.crn}"
      identifier = ibm_resource_instance.app_config.crn
    }
  ]
  account_group_ids_to_assign = var.config_aggregator_enterprise_account_group_ids_to_assign
  account_ids_to_assign       = var.config_aggregator_enterprise_account_ids_to_assign
  policy_templates = [
    {
      name        = "identity-access"
      description = "Policy template for identity services"
      roles       = ["Viewer", "Reader"]
      attributes = [{
        key      = "serviceType"
        value    = "service" # assigns access to All Identity and Access enabled services
        operator = "stringEquals"
      }]
    },
    {
      name        = "platform-access"
      description = "Policy template for platform services"
      roles       = ["Viewer", "Service Configuration Reader"]
      attributes = [{
        key      = "serviceType"
        value    = "platform_service" # assigns access to All Account Management services
        operator = "stringEquals"
      }]
    }
  ]
}

# Define an aggregation
resource "ibm_config_aggregator_settings" "config_aggregator_settings" {
  count                       = var.enable_config_aggregator ? 1 : 0
  instance_id                 = ibm_resource_instance.app_config.guid
  region                      = ibm_resource_instance.app_config.location
  resource_collection_regions = var.config_aggregator_resource_collection_regions
  resource_collection_enabled = true
  trusted_profile_id          = module.config_aggregator_trusted_profile[0].profile_id

  dynamic "additional_scope" {
    for_each = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? [1] : []
    content {
      type          = "Enterprise"
      enterprise_id = var.config_aggregator_enterprise_id
      profile_template {
        id                 = module.config_aggregator_trusted_profile_template[0].trusted_profile_template_id
        trusted_profile_id = module.config_aggregator_trusted_profile_enterprise[0].profile_id
      }
    }
  }
}

##############################################################################
# Context Based Restrictions
##############################################################################

module "cbr_rule" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.32.3"
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
