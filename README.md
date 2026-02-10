# Terraform IBM App Configuration

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-app-configuration?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

Create an App Configuration instance and optionally allows for multiple App Configuration Collections to be created.

<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-app-configuration](#terraform-ibm-app-configuration)
* [Examples](./examples)
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
    * <a href="./examples/advanced">Advanced example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=app-configuration-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
    * <a href="./examples/basic">Basic example</a> <a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=app-configuration-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-app-configuration/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom; margin-left: 5px;"></a>
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-app-configuration

### Usage

```hcl
module "app_config" {
  source                       = "terraform-ibm-modules/app-configuration/ibm"
  version                      = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id            = "65xxxxxxxxxxxxxxxa3fd"
  region                       = "us-south"
  app_config_name              = "my-app-config-name"
  app_config_plan              = "lite"
  app_config_service_endpoints = "public"
  app_config_tags              = ["list", "of", "tags"]

  app_config_collections = [
    {
      name          = "my-app-config-collection-name",
      collection_id = "my-app-config-collection-id",
      description   = "Collection for app config instance",
      tags          = "tag for collection"
    },
    {
      name          = "second-collection-name",
      collection_id = "second-collection-id",
      description   = "Another Collection for app config instance",
      tags          = "another tag"
    }
  ]
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Service
    - **Resource group only**
        - `Viewer` access on the specific resource group
    - **App Configuration**
        - `Administrator` platform access
        - `Manager` service access
    - **All Account Management services** (If setting `enable_config_aggregator` to true)
        - `Administrator` platform access
    - **All Identity and Access enabled services** (If setting `enable_config_aggregator` to true)
        - `Administrator` platform access
    - **Enterprise** (If setting `enable_config_aggregator` to true **and** deploying on an enterprise account)
        - `Viewer` platform access
    - **All IAM Account Management services** (If setting `enable_config_aggregator` to true **and** deploying on an enterprise account)
        - `Template Administrator` platform access
        - `Assignment Administrator` platform access

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.86.0, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.35.13 |
| <a name="module_config_aggregator_trusted_profile"></a> [config\_aggregator\_trusted\_profile](#module\_config\_aggregator\_trusted\_profile) | terraform-ibm-modules/trusted-profile/ibm | 3.2.19 |
| <a name="module_config_aggregator_trusted_profile_enterprise"></a> [config\_aggregator\_trusted\_profile\_enterprise](#module\_config\_aggregator\_trusted\_profile\_enterprise) | terraform-ibm-modules/trusted-profile/ibm | 3.2.19 |
| <a name="module_config_aggregator_trusted_profile_template"></a> [config\_aggregator\_trusted\_profile\_template](#module\_config\_aggregator\_trusted\_profile\_template) | terraform-ibm-modules/trusted-profile/ibm//modules/trusted-profile-template | 3.2.19 |
| <a name="module_en_crn_parser"></a> [en\_crn\_parser](#module\_en\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |
| <a name="module_kms_crn_parser"></a> [kms\_crn\_parser](#module\_kms\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.4.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_app_config_collection.collections](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/app_config_collection) | resource |
| [ibm_app_config_integration_en.app_config_integration_en](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/app_config_integration_en) | resource |
| [ibm_app_config_integration_kms.app_config_integration_kms](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/app_config_integration_kms) | resource |
| [ibm_config_aggregator_settings.config_aggregator_settings](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/config_aggregator_settings) | resource |
| [ibm_iam_authorization_policy.en_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_authorization_policy.kms_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_custom_role.template_assignment_reader](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_custom_role) | resource |
| [ibm_resource_instance.app_config](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [random_string.en_integration_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.kms_integration_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_en_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_kms_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_config_collections"></a> [app\_config\_collections](#input\_app\_config\_collections) | A list of collections to be added to the App Configuration instance | <pre>list(object({<br/>    name          = string<br/>    collection_id = string<br/>    description   = optional(string, null)<br/>    tags          = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_app_config_event_notifications_source_name"></a> [app\_config\_event\_notifications\_source\_name](#input\_app\_config\_event\_notifications\_source\_name) | The name by which Event Notifications source will be created in the existing Event Notification instance. | `string` | `"app-config-en-source-name"` | no |
| <a name="input_app_config_name"></a> [app\_config\_name](#input\_app\_config\_name) | Name for the App Configuration service instance | `string` | n/a | yes |
| <a name="input_app_config_plan"></a> [app\_config\_plan](#input\_app\_config\_plan) | Plan for the App Configuration service instance, valid plans are lite, basic, standardv2, and enterprise. | `string` | `"lite"` | no |
| <a name="input_app_config_service_endpoints"></a> [app\_config\_service\_endpoints](#input\_app\_config\_service\_endpoints) | Service Endpoints for the App Configuration service instance, valid endpoints are public or public-and-private. | `string` | `"public-and-private"` | no |
| <a name="input_app_config_tags"></a> [app\_config\_tags](#input\_app\_config\_tags) | Optional list of tags to be added to the App Config instance. | `list(string)` | `[]` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The context-based restrictions rule to create. Only one rule is allowed. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_config_aggregator_enterprise_account_group_ids_to_assign"></a> [config\_aggregator\_enterprise\_account\_group\_ids\_to\_assign](#input\_config\_aggregator\_enterprise\_account\_group\_ids\_to\_assign) | A list of enterprise account group IDs to assign the trusted profile template to in order for the accounts to be scanned. Supports passing the string 'all' in the list to assign to all account groups. Only applies if `enable_config_aggregator` is true and a value is being passed for `config_aggregator_enterprise_id`. | `list(string)` | <pre>[<br/>  "all"<br/>]</pre> | no |
| <a name="input_config_aggregator_enterprise_account_ids_to_assign"></a> [config\_aggregator\_enterprise\_account\_ids\_to\_assign](#input\_config\_aggregator\_enterprise\_account\_ids\_to\_assign) | A list of enterprise account IDs to assign the trusted profile template to in order for the accounts to be scanned. Supports passing the string 'all' in the list to assign to all accounts. Only applies if `enable_config_aggregator` is true and a value is being passed for `config_aggregator_enterprise_id`. | `list(string)` | `[]` | no |
| <a name="input_config_aggregator_enterprise_id"></a> [config\_aggregator\_enterprise\_id](#input\_config\_aggregator\_enterprise\_id) | If the account is an enterprise account, this value should be set to the enterprise ID (NOTE: This is different to the account ID). | `string` | `null` | no |
| <a name="input_config_aggregator_enterprise_trusted_profile_name"></a> [config\_aggregator\_enterprise\_trusted\_profile\_name](#input\_config\_aggregator\_enterprise\_trusted\_profile\_name) | The name to give the enterprise viewer trusted profile with that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`. | `string` | `"config-aggregator-enterprise-trusted-profile"` | no |
| <a name="input_config_aggregator_enterprise_trusted_profile_template_name"></a> [config\_aggregator\_enterprise\_trusted\_profile\_template\_name](#input\_config\_aggregator\_enterprise\_trusted\_profile\_template\_name) | The name to give the trusted profile template that will be created if `enable_config_aggregator` is set to `true` and a value is passed for `config_aggregator_enterprise_id`. | `string` | `"config-aggregator-trusted-profile-template"` | no |
| <a name="input_config_aggregator_resource_collection_regions"></a> [config\_aggregator\_resource\_collection\_regions](#input\_config\_aggregator\_resource\_collection\_regions) | From which region do you want to collect configuration data? Only applies if `enable_config_aggregator` is set to true. | `list(string)` | <pre>[<br/>  "all"<br/>]</pre> | no |
| <a name="input_config_aggregator_trusted_profile_name"></a> [config\_aggregator\_trusted\_profile\_name](#input\_config\_aggregator\_trusted\_profile\_name) | The name to give the trusted profile that will be created if `enable_config_aggregator` is set to `true`. | `string` | `"config-aggregator-trusted-profile"` | no |
| <a name="input_enable_config_aggregator"></a> [enable\_config\_aggregator](#input\_enable\_config\_aggregator) | Set to true to enable configuration aggregator. By setting to true a trusted profile will be created with the required access to record configuration data from all resources across regions in your account. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-configuration-aggregator). | `bool` | `false` | no |
| <a name="input_enable_event_notifications"></a> [enable\_event\_notifications](#input\_enable\_event\_notifications) | Flag to enable the event notification when the configured plan is 'enterprise'. | `bool` | `false` | no |
| <a name="input_event_notifications_endpoint_url"></a> [event\_notifications\_endpoint\_url](#input\_event\_notifications\_endpoint\_url) | The URL of the Event Notifications service endpoint to use for notifying configuration changes. For more information on the endpoint URL for Event Notifications, go to [Service endpoints](https://cloud.ibm.com/docs/event-notifications?topic=event-notifications-en-regions-endpoints#en-service-endpoints). It is required if `enable_event_notifications` is set to true. | `string` | `null` | no |
| <a name="input_event_notifications_integration_description"></a> [event\_notifications\_integration\_description](#input\_event\_notifications\_integration\_description) | The description of integration between Event Notification and App Configuration service. | `string` | `"The App Configuration integration to send notifications of events of users"` | no |
| <a name="input_existing_event_notifications_instance_crn"></a> [existing\_event\_notifications\_instance\_crn](#input\_existing\_event\_notifications\_instance\_crn) | The CRN of the existing Event Notifications instance to enable notifications for your App Configuration instance. It is required if `enable_event_notifications` is set to true | `string` | `null` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of the Hyper Protect Crypto Services or Key Protect instance. Required only if `var.kms_encryption_enabled` is set to `true`. | `string` | `null` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Flag to enable the KMS encryption when the configured plan is 'enterprise'. | `bool` | `false` | no |
| <a name="input_kms_endpoint_url"></a> [kms\_endpoint\_url](#input\_kms\_endpoint\_url) | The URL of the key management service endpoint to use for key encryption. For more information on the endpoint URL format for Hyper Protect Crypto Services, go to [Instance-based endpoints](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-regions#new-service-endpoints). For more information on the endpoint URL format for Key Protect, go to [Service endpoints](https://cloud.ibm.com/docs/key-protect?topic=key-protect-regions#service-endpoints). It is required if `kms_encryption_enabled` is set to true. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the App Configuration service, valid regions are au-syd, jp-osa, jp-tok, eu-de, eu-gb, eu-es, us-east, us-south, ca-tor, br-sao, eu-fr2, ca-mon. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_root_key_id"></a> [root\_key\_id](#input\_root\_key\_id) | The key ID of a root key, existing in the key management service instance passed in `var.existing_kms_instance_crn`, which is used to encrypt the data encryption keys which are then used to encrypt the data. Required only if `var.kms_encryption_enabled` is set to `true`. | `string` | `null` | no |
| <a name="input_skip_app_config_event_notifications_auth_policy"></a> [skip\_app\_config\_event\_notifications\_auth\_policy](#input\_skip\_app\_config\_event\_notifications\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to integrate with Event Notification in the same account. | `bool` | `false` | no |
| <a name="input_skip_app_config_kms_auth_policy"></a> [skip\_app\_config\_kms\_auth\_policy](#input\_skip\_app\_config\_kms\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to read the encryption key from the KMS instance in the same account. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_config_account_id"></a> [app\_config\_account\_id](#output\_app\_config\_account\_id) | Account ID of the App Configuration instance |
| <a name="output_app_config_collection_ids"></a> [app\_config\_collection\_ids](#output\_app\_config\_collection\_ids) | List of IDs for the collections in the App Configuration instance |
| <a name="output_app_config_crn"></a> [app\_config\_crn](#output\_app\_config\_crn) | CRN of the App Configuration instance |
| <a name="output_app_config_guid"></a> [app\_config\_guid](#output\_app\_config\_guid) | GUID of the App Configuration instance |
| <a name="output_app_config_id"></a> [app\_config\_id](#output\_app\_config\_id) | ID of the App Configuration instance |
| <a name="output_config_aggregator_enterprise_trusted_profile_id"></a> [config\_aggregator\_enterprise\_trusted\_profile\_id](#output\_config\_aggregator\_enterprise\_trusted\_profile\_id) | ID of the config aggregator trusted profile for enterprise access |
| <a name="output_config_aggregator_enterprise_trusted_profile_template_id"></a> [config\_aggregator\_enterprise\_trusted\_profile\_template\_id](#output\_config\_aggregator\_enterprise\_trusted\_profile\_template\_id) | ID of the config aggregator trusted profile enterprise template ID |
| <a name="output_config_aggregator_trusted_profile_id"></a> [config\_aggregator\_trusted\_profile\_id](#output\_config\_aggregator\_trusted\_profile\_id) | ID of the config aggregator trusted profile |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
