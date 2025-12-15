// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

/*
Global variables
*/
const resourceGroup = "geretain-test-resources"
const advancedExampleDir = "examples/advanced"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"
const fullyConfigFlavorDir = "solutions/fully-configurable"
const terraformVersion = "terraform_v1.12.2" // This should match the version in the ibm_catalog.json

var validRegions = []string{
	"au-syd",
	"jp-osa",
	"jp-tok",
	"eu-de",
	"eu-gb",
	"eu-es",
	"us-south",
	"ca-tor",
	"br-sao",
}
var appConfigCollection = []map[string]any{
	{
		"name":          "feature-flags",
		"collection_id": "feature-flags-001",
		"description":   "Feature flags for dev environment",
		"tags":          "type:feature",
	},
}
var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {

	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func TestRunAdvancedExampleInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "en-fs",
		TarIncludePatterns: []string{
			"*.tf",
			advancedExampleDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         advancedExampleDir,
		Tags:                   []string{"test-schematic", "app-config-adv-ex"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
		TerraformVersion:       terraformVersion,
		Region:                 validRegions[common.CryptoIntn(len(validRegions))],
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func provisionPreReq(t *testing.T, p string) (string, *terraform.Options, error) {
	// ------------------------------------------------------------------------------------
	// Provision existing resources first
	// ------------------------------------------------------------------------------------
	prefix := fmt.Sprintf("%s-%s", p, strings.ToLower(random.UniqueId()))
	realTerraformDir := "./existing-resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, prefix)

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix": prefix,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		// assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
		return "", nil, existErr
	}
	return prefix, existingTerraformOptions, nil
}

func TestFullyConfigurable(t *testing.T) {
	t.Parallel()

	prefix, existingTerraformOptions, existErr := provisionPreReq(t, "app-int")

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp pre-req resource failed")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				fullyConfigFlavorDir + "/*.tf",
			},
			TemplateFolder:         fullyConfigFlavorDir,
			Tags:                   []string{"test-schematic", "app-config-da-fc-int"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
			TerraformVersion:       terraformVersion,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
			{Name: "app_config_collections", Value: appConfigCollection, DataType: "list(object)"},
			{Name: "app_config_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "enable_config_aggregator", Value: true, DataType: "bool"},
			{Name: "kms_encryption_enabled", Value: true, DataType: "bool"},
			{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
			{Name: "kms_endpoint_url", Value: permanentResources["hpcs_south_private_endpoint"], DataType: "string"},
			{Name: "enable_event_notifications", Value: true, DataType: "bool"},
			{Name: "existing_event_notifications_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "event_notifications_instance_crn"), DataType: "string"},
			{Name: "event_notifications_endpoint_url", Value: terraform.Output(t, existingTerraformOptions, "event_notification_endpoint_url"), DataType: "string"},
		}

		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

func TestUpgradeFullyConfigurable(t *testing.T) {
	t.Parallel()

	prefix, existingTerraformOptions, existErr := provisionPreReq(t, "app-upg")

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp pre-req resource failed")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				fullyConfigFlavorDir + "/*.tf",
			},
			TemplateFolder:             fullyConfigFlavorDir,
			Tags:                       []string{"test-schematic", "app-config-da-upg"},
			DeleteWorkspaceOnFail:      false,
			WaitJobCompleteMinutes:     60,
			CheckApplyResultForUpgrade: true,
			TerraformVersion:           terraformVersion,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "existing_resource_group_name", Value: resourceGroup, DataType: "string"},
			{Name: "app_config_collections", Value: appConfigCollection, DataType: "list(object)"},
			{Name: "app_config_tags", Value: options.Tags, DataType: "list(string)"},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "enable_config_aggregator", Value: true, DataType: "bool"},
			{Name: "kms_encryption_enabled", Value: true, DataType: "bool"},
			{Name: "existing_kms_instance_crn", Value: permanentResources["hpcs_south_crn"], DataType: "string"},
			{Name: "kms_endpoint_url", Value: permanentResources["hpcs_south_private_endpoint"], DataType: "string"},
			{Name: "enable_event_notifications", Value: true, DataType: "bool"},
			{Name: "existing_event_notifications_instance_crn", Value: terraform.Output(t, existingTerraformOptions, "event_notifications_instance_crn"), DataType: "string"},
			{Name: "event_notifications_endpoint_url", Value: terraform.Output(t, existingTerraformOptions, "event_notification_endpoint_url"), DataType: "string"},
		}

		err := options.RunSchematicUpgradeTest()
		if !options.UpgradeTestSkipped {
			assert.Nil(t, err, "This should not have errored")
		}
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

func TestAddonsDefaultConfiguration(t *testing.T) {
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
			"region": validRegions[common.CryptoIntn(len(validRegions))],
		},
	)

	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		// // Disable target / route creation to help prevent hitting quota in account
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_metrics_routing_to_cloud_monitoring": false,
			},
		},
		{
			OfferingName:   "deploy-arch-ibm-activity-tracker",
			OfferingFlavor: "fully-configurable",
			Inputs: map[string]interface{}{
				"enable_activity_tracker_event_routing_to_cloud_logs": false,
			},
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}

func TestAddonsWithDisabledDAs(t *testing.T) {
	t.Parallel()

	options := testaddons.TestAddonsOptionsDefault(&testaddons.TestAddonOptions{
		Testing:       t,
		Prefix:        "appcon-dis",
		ResourceGroup: resourceGroup,
		QuietMode:     true, // Suppress logs except on failure
	})

	options.AddonConfig = cloudinfo.NewAddonConfigTerraform(
		options.Prefix,
		"deploy-arch-ibm-apprapp",
		"fully-configurable",
		map[string]interface{}{
			"region": validRegions[common.CryptoIntn(len(validRegions))],
		},
	)

	options.AddonConfig.Dependencies = []cloudinfo.AddonConfig{
		// Disable AT, ICL, Mon, EN and KMS
		{
			OfferingName:   "deploy-arch-ibm-activity-tracker",
			OfferingFlavor: "fully-configurable",
			Enabled:        core.BoolPtr(false),
		},
		{
			OfferingName:   "deploy-arch-ibm-cloud-logs",
			OfferingFlavor: "fully-configurable",
			Enabled:        core.BoolPtr(false),
		},
		{
			OfferingName:   "deploy-arch-ibm-cloud-monitoring",
			OfferingFlavor: "fully-configurable",
			Enabled:        core.BoolPtr(false),
		},
		{
			OfferingName:   "deploy-arch-ibm-kms",
			OfferingFlavor: "fully-configurable",
			Enabled:        core.BoolPtr(false),
		},
		{
			OfferingName:   "deploy-arch-ibm-event-notifications",
			OfferingFlavor: "fully-configurable",
			Enabled:        core.BoolPtr(false),
		},
	}

	err := options.RunAddonTest()
	require.NoError(t, err)
}
