variable "prefix" {
  description = "Prefix for naming all resources"
  type        = string
}

variable "region" {
  description = "Region where resources will be deployed"
  type        = string
  default     = "us-south"
}

variable "resource_group" {
  description = "Name of existing resource group (if any)"
  type        = string
  default     = null
}

variable "resource_tags" {
  description = "Tags to assign to resources"
  type        = list(string)
  default     = []
}

