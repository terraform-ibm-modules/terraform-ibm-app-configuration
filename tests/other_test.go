// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"fmt"
	"testing"

	"github.com/IBM/go-sdk-core/v5/core"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/cloudinfo"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testaddons"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: "examples/basic",
		Prefix:       "app-conf-basic",
		Region:       validRegions[common.CryptoIntn(len(validRegions))],
	})

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
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
		{Name: "access_tags", Value: permanentResources["accessTags"], DataType: "list"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
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
			"app_config_event_notifications_source_name": fmt.Sprintf("%s-app-cfg-en", options.Prefix),
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
			"app_config_event_notifications_source_name": fmt.Sprintf("%s-app-cfg", options.Prefix),
			"app_config_plan": "lite",
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
