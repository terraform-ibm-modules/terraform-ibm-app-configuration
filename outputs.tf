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
