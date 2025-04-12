
# Config Aggregator Submodule for IBM Cloud App Configuration

This submodule provisions an IBM Cloud Config Aggregator that collects and centralizes configuration data across an enterprise. It integrates with App Configuration and uses IBM IAM trusted profiles and templates to enable secure, scoped access to configuration insights across regions and accounts.

## Purpose

The `config_aggregator` module is designed to set up a configuration aggregator for your App Configuration instance, scoped either to a single account or to an IBM Cloud Enterprise. It helps consolidate resources and enforce policies across a multi-account environment by leveraging IAM Trusted Profiles and Templates.

## Use Case

Use this module when you want to:

- Enable centralized collection of resource metadata.
- Apply IAM templates and trusted profiles to configure access.
- Scope configuration insights to your enterprise.
- Automatically enable resource collection across all regions.

## Example Usage

```hcl
module "config_aggregator" {
  source = "../../modules/config_aggregator"

  app_config_instance_guid      = module.app_config.app_config_guid
  region                        = var.region
  enterprise_id                 = var.enterprise_id
  general_trusted_profile_id    = module.trusted_profiles.trusted_profile_app_config_general.profile_id
  enterprise_trusted_profile_id = module.trusted_profiles.trusted_profile_app_config_enterprise.profile_id
  trusted_profile_template_id   = module.trusted_profiles.trusted_profile_template_id
}
```

## Inputs

| Name                         | Description                                                                 | Type   | Required |
|------------------------------|-----------------------------------------------------------------------------|--------|----------|
| `app_config_instance_guid`   | GUID of the IBM App Configuration instance                                 | string | yes      |
| `region`                     | IBM Cloud region where the App Config and aggregator are deployed          | string | yes      |
| `enterprise_id`              | Enterprise ID used to scope the aggregator and profile templates           | string | yes      |
| `general_trusted_profile_id`| Trusted profile ID for general collection access                           | string | yes      |
| `enterprise_trusted_profile_id` | Trusted profile ID used for enterprise-level scoped access               | string | yes      |
| `trusted_profile_template_id`| Template ID used to assign profiles to account groups                      | string | yes      |

## Outputs

None currently.

## Resources Created

- `ibm_config_aggregator_settings` — The main resource that defines configuration aggregation settings.

## Behavior

This submodule enables the following behavior:

- **Resource collection** is enabled by default.
- **All regions** are included in the resource collection.
- **Enterprise scope** is configured through `additional_scope`, using the provided `enterprise_id`, `trusted_profile_template_id`, and `enterprise_trusted_profile_id`.

## Related Documentation

- [IBM Cloud App Configuration Documentation](https://cloud.ibm.com/docs/app-configuration)
- [Terraform IBM Provider](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/config_aggregator_settings)
- [IBM Cloud IAM Trusted Profiles](https://cloud.ibm.com/docs/account?topic=account-iamtrustedprofile)

## Notes

- Ensure that the `trusted_profile_template_id` and both trusted profile IDs are correctly created and propagated before using this module.
- This submodule should be used as part of a larger stack that includes trusted profile and App Configuration provisioning.

---

© IBM Corporation 2024
