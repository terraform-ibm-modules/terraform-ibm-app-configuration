##############################################################################
# Provider config
##############################################################################

# Note: visibility is intentionally NOT set to "private" here.
# The IBM Terraform provider always calls the App Configuration public API for
# KMS integration resources (ibm_app_config_integration_kms). Setting
# visibility="private" would cause those calls to fail.
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}
