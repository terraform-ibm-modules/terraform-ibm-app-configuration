# Configuring Context-Based Restrictions (CBRs)

The `app_config_cbr_rules` input variable allows you to provide a rule for the target service to enforce access restrictions for the service based on the context of access requests. Contexts are criteria that include the network location of access requests, the endpoint type from where the request is sent, etc.

- Variable name: `app_config_cbr_rules`.
- Type: A list of objects. Allows only one object representing a rule for the target service
- Default value: An empty list (`[]`).

### Options for app_config_cbr_rules

  - `description` (required): The description of the rule to create.
  - `account_id` (required): The IBM Cloud Account ID
  - `tag` (optional): (List) The tags related to CBR rules
  - `rule_contexts` (required): (List) The contexts the rule applies to
      - `attributes` (optional): (List) Individual context attributes
        - `name` (required): The attribute name.
        - `value`(required): The attribute value.

  - `enforcement_mode` (required): The rule enforcement mode can have the following values:
      - `enabled` - The restrictions are enforced and reported. This is the default.
      - `disabled` - The restrictions are disabled. Nothing is enforced or reported.
      - `report` - The restrictions are evaluated and reported, but not enforced.


### Example Rule For Context-Based Restrictions Configuration

```hcl
[
  {
    description      = "Restrict access to App Config from trusted network"
    account_id       = "<AccountID>"
    enforcement_mode = "enabled"
    tags = [
      {
        name  = "env"
        value = "dev"
      }
    ]
    rule_contexts = [
      {
        attributes = [
          {
            name  = "networkZoneId"
            value = "<NetworkZoneID>"
          },
          {
            "name" : "endpointType",
            "value" : "private"
          }
        ]
      }
    ]
  }
]
```
