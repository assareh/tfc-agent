terraform {
  required_version = ">= 0.12.1"
}

data "tfe_workspace_ids" "all" {
  names        = ["*"]
  organization = var.organization
}

resource "tfe_workspace" "ws-vcs" {
  for_each = {for key, v in var.teams_config : key => v if v.oauth_token_id != ""}
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

resource "tfe_variable" "env_vars" {
  key          = "CONFIRM_DESTROY"
  value        = "1"
  category     = "env"
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "name_prefix" {
  key          = "name_prefix"
  value        = "${var.workspacename}-presto"
  category     = "terraform"
  sensitive    = false
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "tf_vars_txt" {
  count        = length(var.tf_variables)
  key          = element(keys(var.tf_variables), count.index)
  value        = lookup(var.tf_variables, element(keys(var.tf_variables), count.index), "unknown")
  category     = "terraform"
  sensitive    = false
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "tf_vars_sec" {
  count        = length(var.tf_variables_sec)
  key          = element(keys(var.tf_variables_sec), count.index)
  value        = lookup(var.tf_variables_sec, element(keys(var.tf_variables_sec), count.index), "unknown")
  category     = "terraform"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "aws_secret_access_key" {
  count        = var.aws_secret_access_key != "" ? 1 : 0
  key          = "AWS_SECRET_ACCESS_KEY"
  value        = var.aws_secret_access_key
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "aws_access_key_id" {
  count        = var.aws_access_key_id != "" ? 1 : 0
  key          = "AWS_ACCESS_KEY_ID"
  value        = var.aws_access_key_id
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "aws_default_region" {
  count        = var.aws_default_region != "" ? 1 : 0
  key          = "AWS_DEFAULT_REGION"
  value        = var.aws_default_region
  category     = "env"
  sensitive    = false
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "gcp_project" {
  count        = var.gcp_project != "" ? 1 : 0
  key          = "GOOGLE_PROJECT"
  value        = var.gcp_project
  category     = "env"
  sensitive    = false
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "gcp_credentials" {
  count        = var.gcp_credentials != "" ? 1 : 0
  key          = "GOOGLE_CREDENTIALS"
  value        = var.gcp_credentials
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "gcp_region" {
  count        = var.gcp_region != "" ? 1 : 0
  key          = "GOOGLE_REGION"
  value        = var.gcp_region
  category     = "env"
  sensitive    = false
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "gcp_zone" {
  count        = var.gcp_zone != "" ? 1 : 0
  key          = "GOOGLE_ZONE"
  value        = var.gcp_zone
  category     = "env"
  sensitive    = false
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "arm_subscription_id" {
  count        = var.arm_subscription_id != "" ? 1 : 0
  key          = "ARM_SUBSCRIPTION_ID"
  value        = var.arm_subscription_id
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "arm_client_secret" {
  count        = var.arm_client_secret != "" ? 1 : 0
  key          = "ARM_CLIENT_SECRET"
  value        = var.arm_client_secret
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "arm_tenant_id" {
  count        = var.arm_tenant_id != "" ? 1 : 0
  key          = "ARM_TENANT_ID"
  value        = var.arm_tenant_id
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "arm_client_id" {
  count        = var.arm_client_id != "" ? 1 : 0
  key          = "ARM_CLIENT_ID"
  value        = var.arm_client_id
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}

resource "tfe_variable" "env" {
  for_each = var.env
  key          = each.key
  value        = each.value
  category     = "env"
  sensitive    = true
  workspace_id = var.identifier != "" ? ws-vcs[0].id : tfe_workspace.ws-novcs[0].id
  depends_on   = [ws-vcs,tfe_workspace.ws-novcs]
}