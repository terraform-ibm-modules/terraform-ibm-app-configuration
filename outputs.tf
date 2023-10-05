########################################################################################################################
# Outputs
########################################################################################################################

output "app_config_guid" {
  description = "GUID of the App Configuration instance"
  value       = ibm_resource_instance.app_config.guid
}

output "app_config_collection_ids" {
  description = "List of IDs for the collections in the App Configuration instance"
  value       = [for obj in ibm_app_config_collection.collections : obj.collection_id]
}
