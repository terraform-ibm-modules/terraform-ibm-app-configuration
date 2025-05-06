##############################################################################
# Outputs
##############################################################################

output "region" {
  description = "The region all resources were provisioned in"
  value       = var.region
}

output "prefix" {
  description = "The prefix used to name all provisioned resources"
  value       = var.prefix
}

output "resource_group_name" {
  description = "The name of the resource group used"
  value       = module.resource_group.resource_group_name
}

output "app_config_guid" {
  description = "App Configuration GUID"
  value       = module.app_config.app_config_guid
}

output "app_config_crn" {
  description = "CRN of the App Configuration instance"
  value       = module.app_config.app_config_crn
}

output "app_config_id" {
  description = "ID of the App Configuration instance"
  value       = module.app_config.app_config_id
}

output "app_config_account_id" {
  description = "Account ID of the App Configuration instance"
  value       = module.app_config.app_config_account_id
}

output "app_config_collection_ids" {
  description = "App Configuration Collection IDs"
  value       = module.app_config.app_config_collection_ids
}

output "resource_tags" {
  description = "List of resource tags"
  value       = var.resource_tags
}
