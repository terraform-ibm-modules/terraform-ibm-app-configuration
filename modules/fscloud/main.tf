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
  app_config_collections          = var.app_config_collections

  # Configuration aggregator (optional)
  enable_config_aggregator                                   = var.enable_config_aggregator
  config_aggregator_trusted_profile_name                     = var.config_aggregator_trusted_profile_name
  config_aggregator_resource_collection_regions              = var.config_aggregator_resource_collection_regions
  config_aggregator_enterprise_id                            = var.config_aggregator_enterprise_id
  config_aggregator_enterprise_trusted_profile_name          = var.config_aggregator_enterprise_trusted_profile_name
  config_aggregator_enterprise_trusted_profile_template_name = var.config_aggregator_enterprise_trusted_profile_template_name
  config_aggregator_enterprise_account_group_ids_to_assign   = var.config_aggregator_enterprise_account_group_ids_to_assign
  config_aggregator_enterprise_account_ids_to_assign         = var.config_aggregator_enterprise_account_ids_to_assign

  # Event Notifications (optional)
  enable_event_notifications                      = var.enable_event_notifications
  existing_event_notifications_instance_crn       = var.existing_event_notifications_instance_crn
  event_notifications_endpoint_url                = var.event_notifications_endpoint_url
  event_notifications_integration_description     = var.event_notifications_integration_description
  app_config_event_notifications_source_name      = var.app_config_event_notifications_source_name
  skip_app_config_event_notifications_auth_policy = var.skip_app_config_event_notifications_auth_policy
}
