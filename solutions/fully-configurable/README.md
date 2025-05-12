# Cloud automation for App Configuration

### Configuration

This solution supports provisioning and configuring the following infrastructure:

- App Config instance and collections
- Optional context-based restrictions (CBR)
- Configuration aggregator

![app-configuration-deployable-architecture](../../reference-architecture/app_configuration.svg)

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.77.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_config"></a> [app\_config](#module\_app\_config) | ../.. | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.2.0 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_config_cbr_rules"></a> [app\_config\_cbr\_rules](#input\_app\_config\_cbr\_rules) | (Optional, list) A list of context-based restrictions rules to create. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/solutions/fully-configurable/DA-cbr_rules.md). | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_app_config_collections"></a> [app\_config\_collections](#input\_app\_config\_collections) | (Optional, list) A list of collections to be added to the App Configuration instance. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/solutions/fully-configurable/DA-collections.md). | <pre>list(object({<br/>    name          = string<br/>    collection_id = string<br/>    description   = optional(string, null)<br/>    tags          = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_app_config_name"></a> [app\_config\_name](#input\_app\_config\_name) | Name for the App Configuration service instance | `string` | `"app-config"` | no |
| <a name="input_app_config_plan"></a> [app\_config\_plan](#input\_app\_config\_plan) | Plan for the App Configuration service instance | `string` | `"standardv2"` | no |
| <a name="input_app_config_service_endpoints"></a> [app\_config\_service\_endpoints](#input\_app\_config\_service\_endpoints) | Service Endpoints for the App Configuration service instance, valid endpoints are public or public-and-private. | `string` | `"public-and-private"` | no |
| <a name="input_app_config_tags"></a> [app\_config\_tags](#input\_app\_config\_tags) | Optional list of tags to be added to the App Config instance. | `list(string)` | `[]` | no |
| <a name="input_config_aggregator_enterprise_account_group_ids_to_assign"></a> [config\_aggregator\_enterprise\_account\_group\_ids\_to\_assign](#input\_config\_aggregator\_enterprise\_account\_group\_ids\_to\_assign) | A list of enterprise account group IDs to assign the trusted profile template to in order for the accounts to be scanned. Supports passing the string 'all' in the list to assign to all account groups. Only applies if `enable_config_aggregator` is true and a value is being passed for `config_aggregator_enterprise_id`. | `list(string)` | <pre>[<br/>  "all"<br/>]</pre> | no |
| <a name="input_config_aggregator_enterprise_id"></a> [config\_aggregator\_enterprise\_id](#input\_config\_aggregator\_enterprise\_id) | If the account is an enterprise account, this value should be set to the enterprise ID (NOTE: This is different to the account ID). | `string` | `null` | no |
| <a name="input_config_aggregator_enterprise_trusted_profile_name"></a> [config\_aggregator\_enterprise\_trusted\_profile\_name](#input\_config\_aggregator\_enterprise\_trusted\_profile\_name) | The name to give the enterprise viewer trusted profile with that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"config-aggregator-enterprise-trusted-profile"` | no |
| <a name="input_config_aggregator_enterprise_trusted_profile_template_name"></a> [config\_aggregator\_enterprise\_trusted\_profile\_template\_name](#input\_config\_aggregator\_enterprise\_trusted\_profile\_template\_name) | The name to give the trusted profile template that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"config-aggregator-trusted-profile-template"` | no |
| <a name="input_config_aggregator_resource_collection_regions"></a> [config\_aggregator\_resource\_collection\_regions](#input\_config\_aggregator\_resource\_collection\_regions) | From which region do you want to collect configuration data? Only applies if `enable_config_aggregator` is set to true. | `list(string)` | <pre>[<br/>  "all"<br/>]</pre> | no |
| <a name="input_config_aggregator_trusted_profile_name"></a> [config\_aggregator\_trusted\_profile\_name](#input\_config\_aggregator\_trusted\_profile\_name) | The name to give the trusted profile that will be created if `enable_config_aggregator` is set to `true`. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<name>` format. | `string` | `"config-aggregator-trusted-profile"` | no |
| <a name="input_enable_config_aggregator"></a> [enable\_config\_aggregator](#input\_enable\_config\_aggregator) | Set to true to enable configuration aggregator. By setting to true a trusted profile will be created with the required access to record configuration data from all resources across regions in your account. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-configuration-aggregator). | `bool` | `false` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of an existing resource group to provision resource in. | `string` | `"Default"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key used to provision resources. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-us-south. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/solutions/fully-configurable/DA-prefix.md). | `string` | n/a | yes |
| <a name="input_provider_visibility"></a> [provider\_visibility](#input\_provider\_visibility) | Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints). | `string` | `"private"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision resources to. | `string` | `"us-south"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_config_account_id"></a> [app\_config\_account\_id](#output\_app\_config\_account\_id) | Account ID of the App Configuration instance |
| <a name="output_app_config_collection_ids"></a> [app\_config\_collection\_ids](#output\_app\_config\_collection\_ids) | List of IDs for the collections in the App Configuration instance |
| <a name="output_app_config_crn"></a> [app\_config\_crn](#output\_app\_config\_crn) | CRN of the App Configuration instance |
| <a name="output_app_config_guid"></a> [app\_config\_guid](#output\_app\_config\_guid) | GUID of the App Configuration instance |
| <a name="output_app_config_id"></a> [app\_config\_id](#output\_app\_config\_id) | ID of the App Configuration instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
