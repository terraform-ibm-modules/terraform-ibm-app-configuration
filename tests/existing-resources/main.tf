##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.6.1"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Event Notification
##############################################################################

module "event_notifications" {
  source            = "terraform-ibm-modules/event-notifications/ibm"
  version           = "2.12.28"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-en"
  resource_tags     = var.resource_tags
  plan              = "lite"
  service_endpoints = "public-and-private"
  region            = var.region
}

##############################################################################
# Key Protect
##############################################################################

module "key_protect" {
  source                    = "terraform-ibm-modules/kms-all-inclusive/ibm"
  version                   = "5.6.5"
  key_protect_instance_name = "${var.prefix}-key-protect"
  resource_group_id         = module.resource_group.resource_group_id
  region                    = var.region
  resource_tags             = var.resource_tags
  keys = [
    {
      key_ring_name         = "${var.prefix}-app-config-key-ring"
      existing_key_ring     = false
      force_delete_key_ring = true
      keys = [
        {
          key_name                 = "${var.prefix}-app-config-root-key"
          standard_key             = false
          rotation_interval_month  = 3
          dual_auth_delete_enabled = false
          force_delete             = true
        }
      ]
    }
  ]
}
