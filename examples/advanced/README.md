# Advanced example

<!-- There is a pre-commit hook that will take the title of each example add include it in the repos main README.md  -->
<!-- Add text below should describe exactly what resources are provisioned / configured by the example  -->

An end-to-end example that will provision the following:

- A new resource group if one is not passed in.
- A new App Configuration instance.
- A new collection within the App Configuration instance.
- A simple VPC
- A CBR zone for the VPC
- A CBR rule to only allow the App Configuration instance to be accessed from within the VPC zone over private endpoint

