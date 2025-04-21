// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"math/rand"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const completeExampleDir = "examples/complete"
const fullyConfigFlavorDir = "solutions/fully-configurable"

const region = "us-south"

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	validRegions := []string{
		"us-south",
		"us-east",
		"eu-gb",
		"au-syd",
	}
	rand.New(rand.NewSource(time.Now().Unix()))
	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		Region:        validRegions[rand.Intn(len(validRegions))],
		ResourceGroup: resourceGroup,
	})
	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "app-conf", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "app-conf-upg", completeExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func provisionPreReq(t *testing.T) (string, *terraform.Options, error) {
	// ------------------------------------------------------------------------------------
	// Provision existing resources first
	// ------------------------------------------------------------------------------------
	validRegions := []string{
		"us-south",
		"us-east",
		"eu-gb",
		"au-syd",
	}
	prefix := fmt.Sprintf("rssgrp-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := "./existing-resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")
	region := validRegions[rand.Intn(len(validRegions))]
	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix":         prefix,
			"region":         region,
			"resource_group": resourceGroup,
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

	prefix, existingTerraformOptions, existErr := provisionPreReq(t)
	appConfigCollection := []map[string]any{
		{
			"name":          "feature-flags",
			"collection_id": "feature-flags-001",
			"description":   "Feature flags for dev environment",
			"tags":          "type:feature",
		},
	}
	appConfigTags := []string{"owner:goldeneye", "resource:app-config"}

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed for TestFullyConfigurable")
	} else {
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
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "app_config_name", Value: "test-app-config", DataType: "string"},
			{Name: "app_config_plan", Value: "lite", DataType: "string"},
			{Name: "app_config_service_endpoints", Value: "public", DataType: "string"},
			{Name: "app_config_collections", Value: appConfigCollection, DataType: "list(object)"},
			{Name: "app_config_tags", Value: appConfigTags, DataType: "list(string)"},
		}
		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed for TestFullyConfigurable. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

func TestUpgradeFullyConfigurable(t *testing.T) {
	t.Parallel()

	prefix, existingTerraformOptions, existErr := provisionPreReq(t)
	appConfigCollection := []map[string]any{
		{
			"name":          "feature-flags",
			"collection_id": "feature-flags-001",
			"description":   "Feature flags for dev environment",
			"tags":          "type:feature",
		},
	}
	appConfigTags := []string{"owner:goldeneye", "resource:app-config"}

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed for TestUpgradeFullyConfigurable")
	} else {
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
			{Name: "existing_resource_group_name", Value: terraform.Output(t, existingTerraformOptions, "resource_group_name"), DataType: "string"},
			{Name: "app_config_name", Value: "test-app-config", DataType: "string"},
			{Name: "app_config_plan", Value: "lite", DataType: "string"},
			{Name: "app_config_service_endpoints", Value: "public", DataType: "string"},
			{Name: "app_config_collections", Value: appConfigCollection, DataType: "list(object)"},
			{Name: "app_config_tags", Value: appConfigTags, DataType: "list(string)"},
		}
		err := options.RunSchematicUpgradeTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed for TestUpgradeFullyConfigurable. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}
