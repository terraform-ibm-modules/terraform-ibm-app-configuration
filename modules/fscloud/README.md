# Financial Services Cloud Profile

This is a profile for App Configuration that meets Financial Services Cloud requirements.
It has been scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) and meets all applicable goals.

### Usage

```hcl
module "app_config_fscloud" {
  source  = "terraform-ibm-modules/app-configuration/ibm//modules/fscloud"
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release

  resource_group_id         = "a8cff104f1764e98aac9ab879198230a" # pragma: allowlist secret
  app_config_name           = "app-config-fs-cloud"
  region                    = "us-south"
  # Key Protect only — App Configuration no longer supports HPCS integrations as of March 2026.
  # See: https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-relnotes#app-configuration-Mar172026
  existing_kms_instance_crn = "crn:v1:bluemix:public:kms:us-south:a/abac0df06b644a9cabc6e44f55b3880e:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx::"
  root_key_id               = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  kms_endpoint_url          = "https://xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.api.private.us-south.kms.appdomain.cloud"

  cbr_rules = [
    {
      description      = "App Configuration access only from a network zone"
      enforcement_mode = "enabled"
      account_id       = "abac0df06b644a9cabc6e44f55b3880e" # pragma: allowlist secret
      rule_contexts = [{
        attributes = [
          {
            name  = "networkZoneId"
            value = "93a51a1debe2674193217209601dde6f" # pragma: allowlist secret
          }
        ]
      }]
      tags = []
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.89.0, < 3.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_config"></a> [app\_config](#module\_app\_config) | ../../ | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | Add access management tags to the App Configuration instance to control access. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#create-access-console). | `list(string)` | `[]` | no |
| <a name="input_app_config_event_notifications_source_name"></a> [app\_config\_event\_notifications\_source\_name](#input\_app\_config\_event\_notifications\_source\_name) | The name by which Event Notifications source will be created in the existing Event Notification instance. | `string` | `"app-config-en-source-name"` | no |
| <a name="input_app_config_name"></a> [app\_config\_name](#input\_app\_config\_name) | Name for the App Configuration service instance | `string` | n/a | yes |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The list of context-based restrictions rules to create. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>      })))<br/>    }))<br/>    enforcement_mode = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_event_notifications"></a> [enable\_event\_notifications](#input\_enable\_event\_notifications) | Flag to enable the event notification when the configured plan is 'enterprise'. | `bool` | `false` | no |
| <a name="input_event_notifications_endpoint_url"></a> [event\_notifications\_endpoint\_url](#input\_event\_notifications\_endpoint\_url) | The URL of the Event Notifications service endpoint to use for notifying configuration changes. | `string` | `null` | no |
| <a name="input_event_notifications_integration_description"></a> [event\_notifications\_integration\_description](#input\_event\_notifications\_integration\_description) | The description of integration between Event Notification and App Configuration service. | `string` | `"The App Configuration integration to send notifications of events of users"` | no |
| <a name="input_existing_event_notifications_instance_crn"></a> [existing\_event\_notifications\_instance\_crn](#input\_existing\_event\_notifications\_instance\_crn) | The CRN of the existing Event Notifications instance to enable notifications for your App Configuration instance. It is required if `enable_event_notifications` is set to true | `string` | `null` | no |
| <a name="input_existing_kms_instance_crn"></a> [existing\_kms\_instance\_crn](#input\_existing\_kms\_instance\_crn) | The CRN of the Key Protect instance. Required to use Key Protect for FSCloud compliance as App Configuration no longer supports new Hyper Protect Crypto Services (HPCS) integrations. [Learn more](https://cloud.ibm.com/docs/app-configuration?topic=app-configuration-ac-relnotes#app-configuration-Mar172026). | `string` | n/a | yes |
| <a name="input_kms_endpoint_url"></a> [kms\_endpoint\_url](#input\_kms\_endpoint\_url) | The KMS endpoint URL to use when you configure KMS encryption. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the App Configuration service. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Add user resource tags to the App Configuration instance to organize, track, and manage costs. [Learn more](https://cloud.ibm.com/docs/account?topic=account-tag&interface=ui#tag-types). | `list(string)` | `[]` | no |
| <a name="input_root_key_id"></a> [root\_key\_id](#input\_root\_key\_id) | The key ID of a root key, existing in the key management service instance passed in `var.existing_kms_instance_crn`, which is used to encrypt the data encryption keys. | `string` | n/a | yes |
| <a name="input_skip_app_config_event_notifications_auth_policy"></a> [skip\_app\_config\_event\_notifications\_auth\_policy](#input\_skip\_app\_config\_event\_notifications\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to integrate with Event Notification in the same account. | `bool` | `false` | no |
| <a name="input_skip_app_config_kms_auth_policy"></a> [skip\_app\_config\_kms\_auth\_policy](#input\_skip\_app\_config\_kms\_auth\_policy) | Set to true to skip the creation of an IAM authorization policy that permits App configuration instances to read the encryption key from the KMS instance in the same account. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_config_account_id"></a> [app\_config\_account\_id](#output\_app\_config\_account\_id) | Account ID of the App Configuration instance |
| <a name="output_app_config_crn"></a> [app\_config\_crn](#output\_app\_config\_crn) | CRN of the App Configuration instance |
| <a name="output_app_config_guid"></a> [app\_config\_guid](#output\_app\_config\_guid) | GUID of the App Configuration instance |
| <a name="output_app_config_id"></a> [app\_config\_id](#output\_app\_config\_id) | ID of the App Configuration instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
