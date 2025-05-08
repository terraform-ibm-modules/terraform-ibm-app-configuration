# Configuring collections

The `app_config_collections` input variable allows you to define collections to be added to your IBM Cloud App Configuration instance. Collections are logical groupings of configuration items such as feature flags and properties. You can use collections to organize your configuration items based on environments, services, teams, or other criteria.

- Variable name: `app_config_collections`.
- Type: A list of objects. One object per collection item.
- Default value: An empty list (`[]`).

### Options for app_config_collections

  - `name` (required): The name of the collection. This should be a unique, descriptive name identifying the purpose or usage of the collection.
  - `collection_id` (required): The unique ID for the collection. This must be unique within the App Configuration instance.
  - `description` (optional): A brief description of the collection's purpose or contents.
  - `tags` (optional): A string of comma-separated tags that can be used for categorization or filtering.


### Example Collection Configuration

```hcl
[
  {
    name          = "feature-flags"
    collection_id = "ff-collection-001"
    description   = "Feature flags for development environment"
    tags          = "env:dev,team:backend"
  },
  {
    name          = "config-settings-ui"
    collection_id = "cfg-ui-001"
    description   = "Configuration settings for UI components"
    tags          = "env:all,team:frontend"
  }
]
```

* NOTE: When using the `lite` plan, you can define at most 1 App Configuration collection.
