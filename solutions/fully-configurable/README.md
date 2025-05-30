# Cloud automation for App Configuration

[![Catalog release](https://img.shields.io/badge/release-IBM%20Cloud%20Catalog-3662FF?logo=ibm)](https://cloud.ibm.com/catalog/7a4d68b4-cf8b-40cd-a3d1-f49aff526eb3/architecture/deploy-arch-ibm-apprapp-045c1169-d15a-4046-ae81-aa3d3348421f-global)

This solution supports provisioning and configuring the following infrastructure:

- App Config instance and collections
- Optional context-based restrictions (CBR)
- Configuration aggregator

:exclamation: **Important:** This solution is not intended to be called by other modules because it contains a provider configuration and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).
