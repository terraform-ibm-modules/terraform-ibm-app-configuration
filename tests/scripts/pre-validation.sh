#! /bin/bash

############################################################################################################
## This script is used by the catalog pipeline to deploy the Event Notifications
## which are the prerequisites for the fully-configurable app configuration
############################################################################################################

set -e

DA_DIR="solutions/fully-configurable"
TERRAFORM_SOURCE_DIR="tests/existing-resources"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
REGION="us-south"
TF_VARS_FILE="terraform.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning prerequisite event notification.."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "region=\"${REGION}\""
    echo "prefix=\"cus-eng-$(openssl rand -hex 2)\""
  } >>${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  existing_event_notifications_instance_crn="existing_event_notifications_instance_crn"
  existing_event_notifications_instance_crn_value=$(terraform output -state=terraform.tfstate -raw event_notifications_instance_crn)
  event_notifications_endpoint_url="event_notifications_endpoint_url"
  event_notifications_endpoint_url_value=$(terraform output -state=terraform.tfstate -raw event_notification_endpoint_url)

  echo "Appending '${existing_event_notifications_instance_crn}' and '${event_notifications_endpoint_url}' input variable value to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg existing_event_notifications_instance_crn "${existing_event_notifications_instance_crn}" \
    --arg existing_event_notifications_instance_crn_value "${existing_event_notifications_instance_crn_value}" \
    --arg event_notifications_endpoint_url "${event_notifications_endpoint_url}" \
    --arg event_notifications_endpoint_url_value "${event_notifications_endpoint_url_value}" \
    '. + {($existing_event_notifications_instance_crn): $existing_event_notifications_instance_crn_value, ($event_notifications_endpoint_url): $event_notifications_endpoint_url_value}' "${JSON_FILE}" >tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
