terraform {
  required_version = ">= 1.0.5"
}

locals {
  vcs_repo = {
        "identifier" = "ppresto/tfc-agent"
        "oauth_token_id" = "test"
        "repobranch" = "main"
  }
}
 
resource "tfe_workspace" "ws-vcs" {
  name              = var.workspacename
  organization      = var.organization
  terraform_version = var.tfversion
  queue_all_runs    = var.queue_all_runs
  auto_apply        = var.auto_apply
  working_directory = var.workingdir
  global_remote_state = var.global_remote_state != ""  ? true : false
  agent_pool_id     = var.agent_pool_id != "" ? var.agent_pool_id : ""
  execution_mode    = var.agent_pool_id != "" ? "agent" : "remote"

  dynamic "vcs_repo" {
    for_each = local.vcs_repo
    content {
      identifier     = vcs_repo.value.identifier
      oauth_token_id = vcs_repo.value.oauth_token_id
      branch         = vcs_repo.value.repobranch
    }
  }
}

resource "tfe_variable" "tf_variables" {
  for_each     = var.tf_variables
  key          = each.key
  value        = each.value
  category     = "terraform"
  sensitive    = false
  workspace_id = tfe_workspace.ws-vcs.id
}

resource "tfe_variable" "tf_variables_sec" {
  for_each     = var.tf_variables_sec
  key          = each.key
  value        = each.value
  category     = "terraform"
  sensitive    = true
  workspace_id = tfe_workspace.ws-vcs.id
}

resource "tfe_variable" "env_variables" {
  for_each = var.env_variables
  key          = each.key
  value        = each.value
  category     = "env"
  sensitive    = false
  workspace_id = tfe_workspace.ws-vcs.id
}

resource "tfe_variable" "env_variables_sec" {
  for_each = var.env_variables_sec
  key          = each.key
  value        = each.value
  category     = "env"
  sensitive    = true
  workspace_id = tfe_workspace.ws-vcs.id
}