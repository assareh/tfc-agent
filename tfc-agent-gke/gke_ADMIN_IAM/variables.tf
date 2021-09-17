
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
variable "repo_branch" { default = "master"}
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

variable "iam_teams" {
  default = {
    "team1" = {
      "name" : "team1",
      "env" : "dev",
      "gsa" : "gsa-tfc-team1",
      "namespace" : "tfc-team1",
      "k8s_sa" : "tfc-team1-dev",
      "roles" : ["compute.admin","storage.objectAdmin"],
    },
    "team2" = {
      "name" : "team2",
      "env" : "dev",
      "gsa" : "gsa-tfc-team2",
      "namespace" : "tfc-team2",
      "k8s_sa" : "tfc-team2-dev",
      "roles" : ["storage.objectAdmin"],
    }
  }
}

locals {
  iam_team_workspaces = {
    "team1" = {
      "organization" : var.organization
      "workspacename" : "gke_team_team1"
      "workingdir" : "tfc-agent-gke/gke_tfc_team1"
      "tfversion" : "0.13.6"
      "queue_all_runs" : false
      "auto_apply" : true
      "agent_pool_id"     : module.iam-team-setup["team1"].agentpool_id
      "identifier" : "${var.repo_org}/tfc-agent"
      "oauth_token_id" : var.oauth_token_id
      "repobranch" : var.repo_branch
      "env_variables" : {
        "CONFIRM_DESTROY" : 1
        "GOOGLE_REGION"      : var.gcp_region
        "GOOGLE_PROJECT"     : var.gcp_project
        "GOOGLE_ZONE"        : var.gcp_zone
      }
      "env_variables_sec" : {}
      "tf_variables" : {
        "prefix" : "presto"
        "gcp_project" : var.gcp_project
        "gcp_region" : "us-west1"
        "gcp_zone" : "us-west1-c"
      }
      "tf_variables_sec" : {}
    }
    "team2" = {
      "organization" : var.organization
      "workspacename" : "gke_team_team2"
      "workingdir" : "tfc-agent-gke/gke_tfc_team2"
      "tfversion" : "1.0.5"
      "queue_all_runs" : false
      "auto_apply" : true
      "agent_pool_id"     : module.iam-team-setup["team2"].agentpool_id
      "identifier" : "${var.repo_org}/tfc-agent"
      "oauth_token_id" : var.oauth_token_id
      "repobranch" : var.repo_branch
      "env_variables" : {
        "CONFIRM_DESTROY" : 1
        "GOOGLE_REGION"      : var.gcp_region
        "GOOGLE_PROJECT"     : var.gcp_project
        "GOOGLE_ZONE"        : var.gcp_zone
      }
      "env_variables_sec" : {}
      "tf_variables" : {
        "prefix" : "presto"
        "gcp_project" : var.gcp_project
        "gcp_region" : "us-west1"
        "gcp_zone" : "us-west1-c"
      }
      "tf_variables_sec" : {}
    }
  }
}
