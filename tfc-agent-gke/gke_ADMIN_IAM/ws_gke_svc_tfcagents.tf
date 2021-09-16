module "gke_svc_tfcagents" {
    source = "../modules/workspace-mgr"
    agent_pool_id     = ""
    organization = var.organization
    workspacename = "gke_svc_tfcagents"
    workingdir = "tfc-agent-gke/gke_svc_tfcagents"
    tfversion = "1.0.5"
    queue_all_runs = false
    auto_apply = true
    identifier     = "${var.repo_org}/tfc-agent"
    oauth_token_id = var.oauth_token_id
    repo_branch         = var.repo_branch
    global_remote_state = ""
    env_variables = {
        "CONFIRM_DESTROY" : 1
        "GOOGLE_REGION"      : var.gcp_region
        "GOOGLE_PROJECT"     : var.gcp_project
        "GOOGLE_ZONE"        : var.gcp_zone
    }
    env_variables_sec = {
    "GOOGLE_CREDENTIALS" : var.gcp_credentials
    }
    tf_variables = {
        "prefix" = "presto",
        "gcp_project" = var.gcp_project,
        "gcp_region" = "us-west1",
        "gcp_zone" = "us-west1-c",
        "namespace" = "tfc-team1",
        "environment" = "dev",
        "agentpool_tokens" = jsonencode({for t in sort(keys(var.iam_teams)):
            t => {"agent_token" : module.iam-team-setup[t].agent_token}})
    }
    tf_variables_sec = {}
}