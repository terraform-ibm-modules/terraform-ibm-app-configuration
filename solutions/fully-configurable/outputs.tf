########################################################################################################################
# Outputs
########################################################################################################################

output "app_config_guid" {
  description = "GUID of the App Configuration instance"
  value       = module.app_config.app_config_guid
}

output "app_config_collection_ids" {
  description = "List of IDs for the collections in the App Configuration instance"
  value       = module.app_config.app_config_collection_ids
}
