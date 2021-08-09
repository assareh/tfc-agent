module "ws_aws_ecs_tfcagents" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "ws_aws_agent_ecs"
    workingdir = "tfc-agent-ecs-multi/producer"
    tfversion = "0.13.6"
    repobranch = "ecs-mach-profile"
    #Add /Repo_Name after org
    identifier = "${var.repo_org}/tfc-agent"
    oauth_token_id = "${var.oauth_token_id}"
    aws_default_region = "${var.aws_default_region}"
    aws_secret_access_key = "${var.aws_secret_access_key}"
    aws_access_key_id = "${var.aws_access_key_id}"
    aws_session_token = "${var.aws_session_token}"
    tf_variables = {
        "prefix" = "presto"
        "desired_count" = 2
        "max_count" = 10
    }
}