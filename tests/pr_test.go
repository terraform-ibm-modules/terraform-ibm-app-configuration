// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"math/rand"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const advancedExampleDir = "examples/advanced"

const fullyConfigFlavorDir = "solutions/fully-configurable"

var validRegions = []string{
	"au-syd",
	"jp-osa",
	"jp-tok",
	"eu-de",
	"eu-gb",
	"eu-es",
	"us-east",
	"us-south",
	"ca-tor",
	"br-sao",
	"eu-fr2",
	"ca-mon",
}

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	rand.New(rand.NewSource(time.Now().Unix()))
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Prefix:       prefix,
		Region:       validRegions[rand.Intn(len(validRegions))],
		/*
		 Comment out the 'ResourceGroup' input to force this tests to create a unique resource group. This is because
		 there is a restriction with the Event Notification service, which allows only one Lite plan instance per resource group.
		*/
		// ResourceGroup:      resourceGroup,
	})
	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()
	t.Skip()

	options := setupOptions(t, "app-conf", advancedExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestFullyConfigurable(t *testing.T) {
	t.Parallel()
	t.Skip()
	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")
	region := validRegions[rand.Intn(len(validRegions))]
	prefix := "app-da"

	appConfigCollection := []map[string]any{
		{
			"name":          "feature-flags",
			"collection_id": "feature-flags-001",
			"description":   "Feature flags for dev environment",
			"tags":          "type:feature",
		},
	}
	appConfigTags := []string{"owner:goldeneye", "resource:app-config"}

	// ------------------------------------------------------------------------------------
	// Deploy DA
	// ------------------------------------------------------------------------------------
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Region:  region,
		Prefix:  prefix,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/*/*.tf",
			fullyConfigFlavorDir + "/*.tf",
		},
		TemplateFolder:         fullyConfigFlavorDir,
		Tags:                   []string{"app-config-da-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "app_config_name", Value: "test-app-config", DataType: "string"},
		{Name: "app_config_plan", Value: "standardv2", DataType: "string"},
		{Name: "app_config_service_endpoints", Value: "public", DataType: "string"},
		{Name: "app_config_collections", Value: appConfigCollection, DataType: "list(object)"},
		{Name: "app_config_tags", Value: appConfigTags, DataType: "list(string)"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "enable_config_aggregator", Value: true, DataType: "bool"},
	}
	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestUpgradeFullyConfigurable(t *testing.T) {
	t.Parallel()
	t.Skip()
	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")
	region := validRegions[rand.Intn(len(validRegions))]
	prefix := "app-upg"
	appConfigCollection := []map[string]any{
		{
			"name":          "feature-flags",
			"collection_id": "feature-flags-001",
			"description":   "Feature flags for dev environment",
			"tags":          "type:feature",
		},
	}
	appConfigTags := []string{"owner:goldeneye", "resource:app-config"}

	// ------------------------------------------------------------------------------------
	// Deploy DA
	// ------------------------------------------------------------------------------------
	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Region:  region,
		Prefix:  prefix,
		TarIncludePatterns: []string{
			"*.tf",
			"modules/*/*.tf",
			fullyConfigFlavorDir + "/*.tf",
		},
		TemplateFolder:         fullyConfigFlavorDir,
		Tags:                   []string{"app-config-da-test"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
		{Name: "app_config_name", Value: "test-app-config", DataType: "string"},
		{Name: "app_config_plan", Value: "standardv2", DataType: "string"},
		{Name: "app_config_service_endpoints", Value: "public", DataType: "string"},
		{Name: "app_config_collections", Value: appConfigCollection, DataType: "list(object)"},
		{Name: "app_config_tags", Value: appConfigTags, DataType: "list(string)"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "enable_config_aggregator", Value: true, DataType: "bool"},
	}
	err := options.RunSchematicUpgradeTest()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
	}
	assert.Nil(t, err, "This should not have errored")
}

func TestApprappDefaultConfiguration(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "app-def",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-apprapp",
		"fully-configurable",
		map[string]interface{}{
			"prefix": options.Prefix,
			"region": validRegions[rand.Intn(len(validRegions))],
		},
	)

	err := options.RunAddonTest()
	require.NoError(t, err)
}

// TestDependencyPermutations runs dependency permutations for the Event Notifications and all its dependencies
func TestApprappDependencyPermutations(t *testing.T) {
	t.Skip()
	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing: t,
		Prefix:  "app-per",
		AddonConfig: cloudinfo.AddonConfig{
			OfferingName:   "deploy-arch-ibm-apprapp",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"prefix":                       "app-per",
				"region":                       validRegions[rand.Intn(len(validRegions))],
				"existing_resource_group_name": resourceGroup,
			},
		},
	})

	err := options.RunAddonPermutationTest()
	assert.NoError(t, err, "Dependency permutation test should not fail")
}
