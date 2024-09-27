# Terraform IBM App Configuration

[![Stable (Adopted)](https://img.shields.io/badge/Status-Stable%20(Adopted)-yellowgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
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
    * [Basic example](./examples/basic)
    * [Complete example](./examples/complete)
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

* Account Management
  * **All Resource Groups** service
    * `Viewer` platform access
  * IAM Services
    * **App Configuration** service
      * `Administrator` platform access
      * `Manager` service access

For more information on access and permissions, see <https://cloud.ibm.com/docs/account?topic=account-iam-service-roles-actions#apprapp-roles>

<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.65.0, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cbr_rule"></a> [cbr\_rule](#module\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.27.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_app_config_collection.collections](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/app_config_collection) | resource |
| [ibm_resource_instance.app_config](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_instance) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_config_collections"></a> [app\_config\_collections](#input\_app\_config\_collections) | A list of collections to be added to the App Configuration instance | <pre>list(object({<br/>    name          = string<br/>    collection_id = string<br/>    description   = optional(string, null)<br/>    tags          = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_app_config_name"></a> [app\_config\_name](#input\_app\_config\_name) | Name for the App Configuration service instance | `string` | n/a | yes |
| <a name="input_app_config_plan"></a> [app\_config\_plan](#input\_app\_config\_plan) | Plan for the App Configuration service instance, valid plans are lite, standardv2, and enterprise. | `string` | `"lite"` | no |
| <a name="input_app_config_service_endpoints"></a> [app\_config\_service\_endpoints](#input\_app\_config\_service\_endpoints) | Service Endpoints for the App Configuration service instance, valid endpoints are public or public-and-private. | `string` | `"public-and-private"` | no |
| <a name="input_app_config_tags"></a> [app\_config\_tags](#input\_app\_config\_tags) | Optional list of tags to be added to the App Config instance. | `list(string)` | `[]` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The list of context-based restriction rules to create. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the App Configuration service, valid regions are us-south, us-east, eu-gb, and au-syd. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_config_collection_ids"></a> [app\_config\_collection\_ids](#output\_app\_config\_collection\_ids) | List of IDs for the collections in the App Configuration instance |
| <a name="output_app_config_guid"></a> [app\_config\_guid](#output\_app\_config\_guid) | GUID of the App Configuration instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
