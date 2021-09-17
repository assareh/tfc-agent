module "gke_workspace" {
    source = "../modules/workspace-mgr"
    agent_pool_id     = ""
    organization = var.organization
    workspacename = "gke_cluster"
    workingdir = "tfc-agent-gke/gke_cluster"
    tfversion = "1.0.5"
    queue_all_runs = false
    auto_apply = true
    identifier     = "${var.repo_org}/tfc-agent"
    oauth_token_id = var.oauth_token_id
    repo_branch         = var.repo_branch
    global_remote_state = true
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
    "prefix" = "presto"
    "gcp_project" = var.gcp_project
    "gcp_region" = "us-west1"
    "gcp_zone" = "us-west1-c"
    "gke_num_nodes" = 3
    "ip_cidr_range" = "10.10.0.0/24"
    "k8sloadconfig" = true
    "gke_service_account_email" = google_service_account.gke.email
    }
    tf_variables_sec = {
        "tfe_token"      = var.tfe_token
    }
}