module "iam_team_workspaces" {
    source = "../modules/workspace-mgr"
    #for_each = {for key, v in local.iam_team_workspaces : key => v if v.oauth_token_id != ""}
    for_each = local.iam_team_workspaces
    organization = local.iam_team_workspaces[each.key].organization
    workspacename = local.iam_team_workspaces[each.key].workspacename
    workingdir = local.iam_team_workspaces[each.key].workingdir
    tfversion = local.iam_team_workspaces[each.key].tfversion
    queue_all_runs = local.iam_team_workspaces[each.key].queue_all_runs
    auto_apply = local.iam_team_workspaces[each.key].auto_apply
    #vcs_repo = {for team, value in local.iam_team_workspaces: team => value.vcs_repo}
    vcs_repo = {for k,v in local.iam_team_workspaces[each.key]: "repo" => value.vcs_repo
    agent_pool_id     = module.iam-team-setup[each.key].agentpool_id

    env_variables      = local.iam_team_workspaces[each.key].env_variables
    env_variables_sec  = local.iam_team_workspaces[each.key].env_variables_sec
    tf_variables = local.iam_team_workspaces[each.key].tf_variables
    tf_variables_sec = local.iam_team_workspaces[each.key].tf_variables_sec
}
