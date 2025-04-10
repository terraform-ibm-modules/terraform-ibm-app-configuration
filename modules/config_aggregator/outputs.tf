output "config_aggregator_instance_id" {
  description = "App Config instance ID used for aggregation"
  value       = var.app_config_instance_guid
}
output "scc_wp_config_aggregator_id" {
  description = "ID of the SCC-WP Config Aggregator"
  value       = ibm_config_aggregator_settings.scc_wp_aggregator.id
}

