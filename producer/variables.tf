variable "account_id" {
  description = "AWS producer account ID (where tfc-agent will live)"
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
