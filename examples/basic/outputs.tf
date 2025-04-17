########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "resource_group_id" {
  description = "Resource group ID"
  value       = module.resource_group.resource_group_id
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
