##############################################################################
# FSCloud Module Outputs
##############################################################################

output "app_config_crn" {
  description = "CRN of the App Configuration instance"
  value       = module.app_config.app_config_crn
}

output "app_config_id" {
  description = "ID of the App Configuration instance"
  value       = module.app_config.app_config_id
}

output "app_config_guid" {
  description = "GUID of the App Configuration instance"
  value       = module.app_config.app_config_guid
}

output "app_config_account_id" {
  description = "Account ID of the App Configuration instance"
  value       = module.app_config.app_config_account_id
}

output "app_config_collection_ids" {
  description = "App Configuration Collection IDs"
  value       = module.app_config.app_config_collection_ids
}

##############################################################################
# Configuration aggregator
##############################################################################

output "config_aggregator_trusted_profile_id" {
  description = "ID of the config aggregator trusted profile"
  value       = module.app_config.config_aggregator_trusted_profile_id
}

output "config_aggregator_enterprise_trusted_profile_id" {
  description = "ID of the config aggregator trusted profile for enterprise access"
  value       = module.app_config.config_aggregator_enterprise_trusted_profile_id
}

output "config_aggregator_enterprise_trusted_profile_template_id" {
  description = "ID of the config aggregator trusted profile enterprise template ID"
  value       = module.app_config.config_aggregator_enterprise_trusted_profile_template_id
}
