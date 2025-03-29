resource "ibm_config_aggregator_settings" "scc_wp_aggregator" {
  instance_id = var.app_config_instance_guid
  region      = var.region

  resource_collection_regions  = ["all"]
  resource_collection_enabled  = true
  trusted_profile_id           = var.enterprise_trusted_profile_id

  additional_scope {
    type          = "Enterprise"
    enterprise_id = var.enterprise_id
    profile_template {
      id                 = split("/", var.template_id)[0]
      trusted_profile_id = var.enterprise_trusted_profile_id
    }
  }
}

