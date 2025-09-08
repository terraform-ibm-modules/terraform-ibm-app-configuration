output "resource_group_name" {
  value       = module.resource_group.resource_group_name
  description = "Resource group name"
}

output "resource_group_id" {
  value       = module.resource_group.resource_group_id
  description = "Resource group ID"
}

output "prefix" {
  description = "Prefix to append to all resources created by this example."
  value       = var.prefix
}

output "kms_key_crn" {
  value       = module.key_protect.keys["${var.prefix}-ring.${var.prefix}-root-key"].crn
  description = "CRN of created KMS key"
}

output "kms_instance_crn" {
  value       = module.key_protect.key_protect_id
  description = "CRN of created KMS instance"
}

output "event_notifications_instance_crn" {
  value       = module.event_notifications.crn
  description = "CRN of created event notification"
}
