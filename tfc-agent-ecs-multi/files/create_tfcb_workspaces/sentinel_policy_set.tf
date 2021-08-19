resource "tfe_policy_set" "org" {
  #count                  = "${var.policies_org ? 1 : 0}"
  name                   = "policy"
  description            = "Organization Policies"
  organization           = "${var.organization}"
  policies_path          = "governance/third-generation/aws/"
  workspace_ids          = [
    "${local.workspaces["aws_serviceA"]}",
    "${local.workspaces["aws_serviceB"]}"
  ]

  vcs_repo {
    identifier         = "${var.repo_org}/terraform-guides"
    branch             = "master"
    ingress_submodules = false
    oauth_token_id     = "${var.oauth_token_id}"
  }
}

data "tfe_workspace_ids" "all" {
  names        = ["*"]
  organization = "${var.organization}"
}

locals {
  workspaces = "${data.tfe_workspace_ids.all.ids}" # map of names to IDs
}