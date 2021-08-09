module "ws_aws_iam" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "ws_aws_iam"
    workingdir = "tfc-agent-ecs-multi/iam"
    tfversion = "0.13.6"
    repobranch = "ecs-mach-profile"
    #Add /Repo_Name after org
    identifier = "${var.repo_org}/tfc-agent"
    oauth_token_id = "${var.oauth_token_id}"
    aws_default_region = "${var.aws_default_region}"
    aws_secret_access_key = "${var.aws_secret_access_key}"
    aws_access_key_id = "${var.aws_access_key_id}"
    aws_session_token = var.aws_session_token
    tf_variables = {
        "project_name" = "AWS_IAM_PROFILE_ADMIN"
        "prefix" = "presto"
        "organization" = var.organization
    }
    tf_variables_sec = {
        "tfe_token"      = var.tfe_token
    }
}