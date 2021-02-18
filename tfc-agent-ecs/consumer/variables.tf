variable "dev_role_arn" {
  description = "Amazon Resource Name of the dev role to be assumed (this was created in the producer workspace)"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-west-2"
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
