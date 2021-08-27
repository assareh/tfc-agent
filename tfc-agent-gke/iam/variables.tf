variable "gcp_project" {
  description = "GCP project name"
}

variable "gcp_region" {
  description = "GCP region, e.g. us-east1"
  default     = "us-west1"
}

variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-a"
  default     = "us-west1-b"
}

variable "machine_type" {
  description = "GCP machine type"
  default     = "g1-small"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
  default     = "tfc-agent"
}

variable "organization" { default = "presto-projects" }
variable "tfe_token" {
  description = "Terraform Cloud admin token to create agent_pools, agent_tokens. (mark as sensitive)"
}
