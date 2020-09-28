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
  # Common tags to be assigned to all resources
  common_tags = {
    Name    = "Andy Assareh"
    Owner   = "assareh@hashicorp.com"
    Region  = "NA-WEST-ENT"
    Purpose = "Demo the tfc-agent"
    TTL     = var.ttl #hours
    # Optional
    Terraform = "true" # true/false
    TFE       = "true" # true/false
  }
}
