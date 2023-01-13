module "admin_ws_sentinel" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "admin_ws_sentinel"
    workingdir = "governance/third-generation/aws/"
    tfversion = "0.13.6"
    repobranch = "master"
    identifier = "${var.repo_org}/terraform-guides"
    oauth_token_id = "${var.oauth_token_id}"
    #aws_default_region = "${var.aws_default_region}"
    #aws_secret_access_key = "${var.aws_secret_access_key}"
    #aws_access_key_id = "${var.aws_access_key_id}"

    # Insecure - In prod add only the workspaces who should have access.

    tf_variables = {
        "project_name" = "Sentinel_Policy_as_Code"
        "prefix" = "presto"
        "tfe_organization" = var.organization
        "repo_org" = var.repo_org
        "tfe_hostname" = "app.terraform.io"

    }
    tf_variables_sec = {
        "tfe_token"      = var.tfe_token
        "oauth_token_id" = var.oauth_token_id
    }
}