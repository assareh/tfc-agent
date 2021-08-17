module "ADMIN-Sentinel-Policies" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "ADMIN-Sentinel-Policies-NEW"
    workingdir = "tfc-agent-ecs-multi/files/create_tfcb_workspaces/sentinel_ws"
    tfversion = "0.13.6"
    repobranch = "ecs-mach-profile"
    identifier = "${var.repo_org}/tfc-agent"
    oauth_token_id = "${var.oauth_token_id}"
    #aws_default_region = "${var.aws_default_region}"
    #aws_secret_access_key = "${var.aws_secret_access_key}"
    #aws_access_key_id = "${var.aws_access_key_id}"

    # Insecure - In prod add only the workspaces who should have access.

    tf_variables = {
        "project_name" = "Sentinel_Policy_as_Code"
        "prefix" = "presto"
        "organization" = var.organization
    }
    tf_variables_sec = {
        "tfe_token"      = var.tfe_token
    }
}