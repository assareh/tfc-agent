
variable "prefix" {
  description = "Name prefix to add to the resources"
  default     = "tfc-agent"
}

# Workspace Variables
variable "tfe_hostname" {default     = "app.terraform.io"}
variable "organization" { default = "presto-projects" }
variable "tfe_token" {}
variable "oauth_token_id" {}
variable "repo_org" {}
variable "repo_branch" { default = "iam"}
variable "global_remote_state" {default = ""}

# GCP
variable "gcp_credentials" {default = ""}
variable "gcp_project" {default = ""}
variable "gcp_region" {
  description = "GCP region, e.g. us-east1"
  default     = "us-west1"
}
variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-a"
  default     = "us-west1-b"
}
