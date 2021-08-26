variable "tfe_hostname" {default     = "app.terraform.io"}
variable "organization" { default = "presto-projects" }
variable "tfe_token" {}
variable "oauth_token_id" {}
variable "repo_org" {}
variable "global_remote_state" {default = ""}

variable "gcp_credentials" {default = ""}
variable "gcp_region" {default = ""}
variable "gcp_project" {default = ""}
variable "gcp_zone" {default = ""}