terraform {
  required_version = ">= 0.12.1"
}

data "tfe_workspace_ids" "all" {
  names        = ["*"]
  organization = var.organization
}

resource "tfe_workspace" "ws-vcs" {
  name              = var.workspacename
  organization      = var.organization
  terraform_version = var.tfversion
  queue_all_runs    = var.queue_all_runs
  auto_apply        = var.auto_apply
  working_directory = var.workingdir
  global_remote_state = var.global_remote_state != ""  ? true : false

  vcs_repo {
    identifier     = var.identifier
    oauth_token_id = var.oauth_token_id
    branch         = var.repobranch
  }
}

resource "tfe_workspace" "ws-novcs" {
  count             = var.identifier == "" ? 1 : 0
  name              = var.workspacename
  organization      = var.organization
  terraform_version = var.tfversion
  queue_all_runs    = var.queue_all_runs
  auto_apply        = var.auto_apply
  working_directory = var.workingdir
}

resource "tfe_variable" "tf_vars_txt" {
  for_each     = var.tf_variables
  key          = each.key
  value        = each.value
  category     = "terraform"
  sensitive    = false
  workspace_id = tfe_workspace.ws-vcs.id
}

resource "tfe_variable" "tf_vars_sec" {
  for_each     = var.tf_variables_sec
  key          = each.key
  value        = each.value
  category     = "terraform"
  sensitive    = true
  workspace_id = tfe_workspace.ws-vcs.id
}

resource "tfe_variable" "env" {
  for_each = var.env
  key          = each.key
  value        = each.value
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.ws-vcs.id
}