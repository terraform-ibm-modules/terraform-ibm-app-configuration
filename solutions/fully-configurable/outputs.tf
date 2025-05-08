########################################################################################################################
# Outputs
########################################################################################################################

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
  value       = module.app_config.app_config_id
}

output "app_config_collection_ids" {
  description = "List of IDs for the collections in the App Configuration instance"
  value       = module.app_config.app_config_collection_ids
}
