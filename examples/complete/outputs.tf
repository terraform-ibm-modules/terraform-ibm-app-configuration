##############################################################################
# Outputs
##############################################################################
output "scc_wp_config_aggregator_id" {
  description = "ID of the SCC-WP Config Aggregator"
  value       = module.scc_wp_config_aggregator.scc_wp_config_aggregator_id
}

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
  value       = var.resource_group
}

output "app_config_guid" {
  description = "App Configuration GUID"
  value       = module.app_config.app_config_guid
}

output "app_config_collection_ids" {
  description = "App Configuration Collection IDs"
  value       = module.app_config.app_config_collection_ids
}

output "resource_tags" {
  description = "List of resource tags"
  value       = var.resource_tags
}
