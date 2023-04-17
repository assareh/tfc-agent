variable "tfe_hostname" {default     = "app.terraform.io"}
variable "organization" { default = "presto-projects" }
variable "tfe_token" {}
variable "oauth_token_id" {}
variable "repo_org" {}
variable "global_remote_state" {default = ""}

variable "aws_default_region" {default = "us-west-2"}
variable "aws_secret_access_key" {default = ""}
variable "aws_access_key_id" {default = ""}