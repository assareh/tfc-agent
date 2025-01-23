variable "aws_role_arn" {
  description = "Amazon Resource Name of the role to be assumed (this was created in the producer workspace)"
}

variable "cidr_block" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-west-2"
}

variable "TFC_RUN_ID" {
  type        = string
  description = "HCP Terraform automatically injects a unique identifier for this run."
  default     = "terraform"
}

// OPTIONAL Tags
variable "ttl" {
  description = "OPTIONAL for Cloud Custodian; value of ttl tag on cloud resources"
  default     = "1"
}

// OPTIONAL Tags
locals {
  common_tags = {
    owner              = "your-name-here"
    se-region          = "your-region-here"
    purpose            = "Default state is dormant with no active resources. Runs a HCP Terraform Agent when a run is queued."
    ttl                = var.ttl # hours
    terraform          = "true"  # true/false
    hc-internet-facing = "false" # true/false
  }
}
