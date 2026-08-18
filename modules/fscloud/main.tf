##############################################################################
# App Configuration FSCloud Module
##############################################################################

module "app_config" {
  source                          = "../../"
  resource_group_id               = var.resource_group_id
  region                          = var.region
  app_config_name                 = var.app_config_name
  app_config_plan                 = "enterprise"
  app_config_service_endpoints    = "public-and-private"
  kms_encryption_enabled          = true
  existing_kms_instance_crn       = var.existing_kms_instance_crn
  root_key_id                     = var.root_key_id
  kms_endpoint_url                = var.kms_endpoint_url
  skip_app_config_kms_auth_policy = var.skip_app_config_kms_auth_policy
  cbr_rules                       = var.cbr_rules
  access_tags                     = var.access_tags
  resource_tags                   = var.resource_tags

  # Event Notifications (optional)
  enable_event_notifications                      = var.enable_event_notifications
  existing_event_notifications_instance_crn       = var.existing_event_notifications_instance_crn
  event_notifications_endpoint_url                = var.event_notifications_endpoint_url
  event_notifications_integration_description     = var.event_notifications_integration_description
  app_config_event_notifications_source_name      = var.app_config_event_notifications_source_name
  skip_app_config_event_notifications_auth_policy = var.skip_app_config_event_notifications_auth_policy
}
