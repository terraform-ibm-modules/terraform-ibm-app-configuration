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

output "event_notifications_instance_crn" {
  value       = module.event_notifications.crn
  description = "CRN of created event notification"
}

output "event_notification_endpoint_url" {
  value       = module.event_notifications.event_notifications_private_endpoint
  description = "The endpoint URL for event notification instance"
}
