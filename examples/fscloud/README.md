# Financial Services Cloud profile example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<p>
  <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=app-configuration-fscloud-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/examples/fscloud">
    <img src="https://img.shields.io/badge/Deploy%20with%20IBM%20Cloud%20Schematics-0f62fe?style=flat&logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics">
  </a><br>
  ℹ️ Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab.
</p>
<!-- END SCHEMATICS DEPLOY HOOK -->

An end-to-end example that uses the [Profile for IBM Cloud Framework for Financial Services](https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/modules/fscloud) to deploy an instance of App Configuration.

The example uses the IBM Cloud Terraform provider to create the following infrastructure:

- An existing resource group (required — a permanent group must be passed in).
- An IAM authorization between the App Configuration instance and the Key Protect instance that is passed in.
- An App Configuration instance on the `enterprise` plan, encrypted with the Key Protect root key that is passed in.
- A context-based restriction (CBR) rule to only allow App Configuration to be accessible from Schematics.

:exclamation: **Important:** In this example, only the App Configuration instance complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

- You need a Key Protect instance and root key available in `us-south`. App Configuration no longer supports new Hyper Protect Crypto Services (HPCS) integrations as of March 2026. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-relnotes#app-configuration-Mar172026).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.89.0, < 3.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_config"></a> [app\_config](#module\_app\_config) | ../../modules/fscloud | n/a |
| <a name="module_cbr_zone_schematics"></a> [cbr\_zone\_schematics](#module\_cbr\_zone\_schematics) | terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module | 1.36.7 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.6.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | Add access management tags to the App Configuration instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console). | `list(string)` | `[]` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of the Key Protect instance. Required to use Key Protect for FSCloud compliance as App Configuration no longer supports new Hyper Protect Crypto Services (HPCS) integrations. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-relnotes#app-configuration-Mar172026). | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API Key | `string` | n/a | yes |
| <a name="input_kms_endpoint_url"></a> [kms\_endpoint\_url](#input\_kms\_endpoint\_url) | The KMS endpoint URL to use when you configure KMS encryption. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all resources created by this example | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region to provision all resources created by this example | `string` | `"us-south"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The name of an existing resource group to provision resources in to. | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_root_key_crn"></a> [root\_key\_crn](#input\_root\_key\_crn) | The CRN of a root key, existing in the KMS instance passed in var.existing\_kms\_instance\_crn, which will be used to encrypt the data encryption keys (DEKs) which are then used to encrypt the data. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_config_account_id"></a> [app\_config\_account\_id](#output\_app\_config\_account\_id) | Account ID of the App Configuration instance |
| <a name="output_app_config_crn"></a> [app\_config\_crn](#output\_app\_config\_crn) | CRN of the App Configuration instance |
| <a name="output_app_config_guid"></a> [app\_config\_guid](#output\_app\_config\_guid) | App Configuration GUID |
| <a name="output_app_config_id"></a> [app\_config\_id](#output\_app\_config\_id) | ID of the App Configuration instance |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource group ID |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
