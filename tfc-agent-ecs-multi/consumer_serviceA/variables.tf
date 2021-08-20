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
