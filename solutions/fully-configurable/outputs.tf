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

output "next_steps_text" {
  value       = "Your App Config Environment is ready."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to App Config Instance"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/services/apprapp/${module.app_config.app_config_crn}?paneId=manage"
  description = "Primary URL"
}
