module "iam_team_workspaces" {
    source = "../modules/workspace-mgr"
    #for_each = {for key, v in local.iam_team_workspaces : key => v if v.oauth_token_id != ""}
    for_each = local.iam_team_workspaces

    agent_pool_id     = module.iam-team-setup[each.key].agentpool_id

    organization = local.iam_team_workspaces[each.key].organization
    workspacename = local.iam_team_workspaces[each.key].workspacename
    workingdir = local.iam_team_workspaces[each.key].workingdir
    tfversion = local.iam_team_workspaces[each.key].tfversion
    queue_all_runs = local.iam_team_workspaces[each.key].queue_all_runs
    auto_apply = local.iam_team_workspaces[each.key].auto_apply

    identifier     = local.iam_team_workspaces[each.key].identifier
    oauth_token_id = local.iam_team_workspaces[each.key].oauth_token_id
    repo_branch         = local.iam_team_workspaces[each.key].repobranch

    env_variables      = local.iam_team_workspaces[each.key].env_variables
    env_variables_sec  = local.iam_team_workspaces[each.key].env_variables_sec
    tf_variables = local.iam_team_workspaces[each.key].tf_variables
    tf_variables_sec = local.iam_team_workspaces[each.key].tf_variables_sec
}
