
variable "prefix" {
  description = "Name prefix to add to the resources"
  default     = "tfc-agent"
}

# Workspace Variables
variable "tfe_hostname" {default     = "app.terraform.io"}
variable "organization" { default = "presto-projects" }
variable "tfe_token" {}
#variable "oauth_token_id" {}
#variable "repo_org" {}
#variable "repo_branch" { default = "iam"}
#variable "global_remote_state" {default = ""}

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

variable "team" {default = {}}
/*
variable "iam_teams" {
  default = {
    "team1" = {
      "gsa" : "gsa-tfc-team1",
      "namespace" : "tfc-team1",
      "k8a_sa" : "tfc-agent-dev",
      "roles" : ["compute.admin","storage.objectAdmin"],
    }
  }
}

locals {
  team_roles = flatten([for team, value in var.iam_teams:
                   flatten([for role in value.roles:
                    {"team" = team
                    "role" = role}
                   ])
                ])
}

output "team_roles" {
  value = local.team_roles
}
*/

