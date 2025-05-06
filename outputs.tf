########################################################################################################################
# Outputs
########################################################################################################################

output "app_config_crn" {
  description = "CRN of the App Configuration instance"
  value       = ibm_resource_instance.app_config.crn
}

output "app_config_id" {
  description = "ID of the App Configuration instance"
  value       = ibm_resource_instance.app_config.id
}

output "app_config_guid" {
  description = "GUID of the App Configuration instance"
  value       = ibm_resource_instance.app_config.guid
}

output "app_config_account_id" {
  description = "Account ID of the App Configuration instance"
  value       = ibm_resource_instance.app_config.account_id
}

output "app_config_collection_ids" {
  description = "List of IDs for the collections in the App Configuration instance"
  value       = [for obj in ibm_app_config_collection.collections : obj.collection_id]
}

##############################################################################
# Configuration aggregator
##############################################################################

output "config_aggregator_trusted_profile_id" {
  description = "ID of the config aggregator trusted profile"
  value       = var.enable_config_aggregator ? module.config_aggregator_trusted_profile[0].profile_id : null
}

output "config_aggregator_enterprise_trusted_profile_id" {
  description = "ID of the config aggregator trusted profile for enterprise access"
  value       = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? module.config_aggregator_trusted_profile_enterprise[0].profile_id : null
}

output "config_aggregator_enterprise_trusted_profile_template_id" {
  description = "ID of the config aggregator trusted profile enterprise template ID"
  value       = var.enable_config_aggregator && var.config_aggregator_enterprise_id != null ? module.config_aggregator_trusted_profile_template[0].trusted_profile_template_id : null
}
