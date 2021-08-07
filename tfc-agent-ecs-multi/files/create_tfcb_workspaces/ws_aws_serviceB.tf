module "ws_aws_serviceB" {
    #source  = "app.terraform.io/presto-projects/tfe-workspace/mod"
    source = "../modules/workspace-agent"
    agent_pool_id     = data.terraform_remote_state.presto_projects_ws_aws_iam.outputs.serviceB_agentpool_id
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "ws_aws_serviceB"
    workingdir = "tfc-agent-ecs-multi/consumer_serviceB"
    tfversion = "0.13.6"
    repobranch = "ecs-mach-profile"
    #Add /Repo_Name after org
    identifier = "${var.repo_org}/tfc-agent"
    oauth_token_id = "${var.oauth_token_id}"
    aws_default_region = "${var.aws_default_region}"
    tf_variables = {
        "prefix" = "ws_aws_serviceB"
        "dev_role_arn" = "arn:aws:iam::711129375688:role/iam-role-serviceB"
    }
}