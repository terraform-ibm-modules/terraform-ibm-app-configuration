# Tests

For information about how to create and run tests, see [Validation tests](https://terraform-ibm-modules.github.io/documentation/#/tests) in the project documentation.

<!-- Add any more steps that are specific to testing this module and that are not in the docs. -->
The App Configuration service is only available in particular regions, in order to ensure tests are run in a valid region the environment variable `FORCE_TEST_REGION` must be set to a valid region.
