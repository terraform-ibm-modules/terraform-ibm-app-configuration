output "app_config_crn" {
  value = ibm_resource_instance.app_config.crn
}

output "app_config_guid" {
  description = "GUID of the App Configuration instance"
  value       = module.app_config.app_config_guid
}

output "app_config_collection_ids" {
  description = "List of IDs for the collections in the App Configuration instance"
  value       = module.app_config.app_config_collection_ids
}

output "resource_group_name" {
  description = "Name of the resource group used"
  value       = var.resource_group
}

output "vpc_id" {
  description = "ID of the created VPC"
  value       = ibm_is_vpc.example_vpc.id
}

