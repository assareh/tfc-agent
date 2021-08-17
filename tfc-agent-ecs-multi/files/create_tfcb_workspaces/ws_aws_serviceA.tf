module "aws_serviceA" {
    #source  = "app.terraform.io/presto-projects/tfe-workspace/mod"
    source = "../modules/workspace-agent"
    agent_pool_id     = data.terraform_remote_state.presto_projects_aws_iam.outputs.serviceA_agentpool_id
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "aws_serviceA"
    workingdir = "tfc-agent-ecs-multi/consumer_serviceA"
    tfversion = "0.13.6"
    repobranch = "ecs-mach-profile"
    #Add /Repo_Name after org
    identifier = "${var.repo_org}/tfc-agent"
    oauth_token_id = "${var.oauth_token_id}"
    aws_default_region = "${var.aws_default_region}"
    tf_variables = {
        "prefix" = "aws_serviceA"
        "dev_role_arn" = "arn:aws:iam::711129375688:role/iam-role-serviceA"
    }
}