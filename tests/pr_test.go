// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"math/rand"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const completeExampleDir = "examples/complete"

func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	validRegions := []string{
		"us-south",
		"us-east",
		"eu-gb",
		"au-syd",
	}
	rand.Seed(time.Now().Unix())
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
