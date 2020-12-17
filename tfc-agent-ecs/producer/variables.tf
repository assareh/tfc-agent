variable "app_version" {
  description = "Version of lambda to deploy"
  default     = "1.0.0"
}

variable "desired_count" {
  description = "Desired count of tfc-agents to run. Suggested 2 * run concurrency. Default TFCB concurrency is 2. May want to set this lower as desired if using lamdba autoscaling."
  default     = 4
}

variable "max_count" {
  description = "Maximum count of tfc-agents to run. Suggested 2 * run concurrency. Default TFCB concurrency is 2."
  default     = 4
}

variable "notification_token" {
  description = "Used to generate the HMAC on the notification request. Read more in the documentation."
  default     = "SuperSecret!!"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-west-2"
}

variable "tfc_agent_token" {
  description = "Terraform Cloud agent token. (mark as sensitive) (TFC Organization Settings >> Agents)"
}

// Tags
variable "ttl" {
  description = "optional value of ttl tag on cloud resources"
  default     = "1"
}

locals {
  common_tags = {
    owner     = "assareh"
    se-region = "AMER - West E2 - R2"
    purpose   = "Demo Terraform and Vault"
    ttl       = var.ttl # hours
    terraform = "true"  # true/false
  }
}
