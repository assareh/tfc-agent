variable "dev_role_arn" {
  description = "Amazon Resource Name of the dev role to be assumed (this was created in the producer workspace)"
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
    owner              = "presto-serviceB"
    se-region          = "norcal"
    purpose            = "A demo instance."
    ttl                = var.ttl # hours
    terraform          = "true"  # true/false
    hc-internet-facing = "false" # true/false
  }
}
