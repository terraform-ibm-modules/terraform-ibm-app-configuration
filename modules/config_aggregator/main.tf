
resource "ibm_config_aggregator_settings" "scc_wp_aggregator" {
  instance_id                 = var.app_config_instance_guid
  region                      = var.region
  resource_collection_enabled = true
  resource_collection_regions = ["all"]
  trusted_profile_id          = var.general_trusted_profile_id

  additional_scope {
    type          = "Enterprise"
    enterprise_id = var.enterprise_id

    profile_template {
    id = var.trusted_profile_template_id
    trusted_profile_id = var.enterprise_trusted_profile_id
    }
  }
}

