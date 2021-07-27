resource "tfe_policy_set" "org" {
  #count                  = "${var.policies_org ? 1 : 0}"
  name                   = "policy"
  description            = "Organization Policies"
  organization           = "${var.tfe_organization}"
  policies_path          = "governance/third-generation/aws/"
  workspace_ids          = [
    "${local.workspaces["ws_aws_serviceA"]}",
    "${local.workspaces["ws_aws_serviceB"]}"
  ]

  vcs_repo {
    identifier         = "${var.repo_org}/terraform-guides"
    branch             = "master"
    ingress_submodules = false
    oauth_token_id     = "${var.oauth_token_id}"
  }
}

provider "tfe" {
  hostname = "${var.tfe_hostname}"
  token    = "${var.tfe_token}"
  #version  = "~> 0.6"
}

data "tfe_workspace_ids" "all" {
  names        = ["*"]
  organization = "${var.tfe_organization}"
}

locals {
  workspaces = "${data.tfe_workspace_ids.all.ids}" # map of names to IDs
}

variable "tfe_token" {}

variable "tfe_hostname" {
  description = "The domain where your TFE is hosted."
  default     = "app.terraform.io"
}
variable "tfe_organization" {
  description = "The TFE organization to apply your changes to."
}
variable "repo_org" {}

variable "oauth_token_id" {}
