
variable "prefix" {
  description = "Name prefix to add to the resources"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-west-2"
}

variable "ttl" {
  description = "optional value of ttl tag on cloud resources"
  default     = "1"
}

variable "ecs_agent_pool_serviceA_token" {
  default     = ""
}

variable "ecs_agent_pool_serviceB_token" {
  default     = ""
}

variable "role_trusted_entities" {
  default     = "arn:aws:iam::711129375688:role/*"
}

# Standard IAM Role Tags
locals {
  common_tags = {
    owner              = "presto"
    se-region          = "norcal"
    purpose            = "Manage multiple IAM roles"
    ttl                = 0 # hours
    terraform          = "true"  # true/false
    hc-internet-facing = "false" # true/false
  }
}