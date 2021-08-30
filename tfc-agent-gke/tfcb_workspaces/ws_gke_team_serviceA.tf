module "gke_team_serviceA" {
    source = "../modules/workspace-agent"
    #agent_pool_id     = data.terraform_remote_state.presto_projects_iam.outputs.serviceA_agentpool_id
    agent_pool_id = "test"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "gke_team_serviceA"
    workingdir = "tfc-agent-gke/gke_team_serviceA"
    tfversion = "0.13.6"
    repobranch = var.repo_branch
    #Add /Repo_Name after org
    identifier = "${var.repo_org}/tfc-agent"
    oauth_token_id = "${var.oauth_token_id}"
    #gcp_credentials = "${var.gcp_credentials}"
    gcp_region      = "${var.gcp_region}"
    gcp_project     = "${var.gcp_project}"
    gcp_zone        = "${var.gcp_zone}"

    # Insecure - In prod add only the workspaces who should have access.
    #global_remote_state = true

    tf_variables = {
        "prefix" = "presto"
        "gcp_project" = var.gcp_project
        "gcp_region" = "us-west1"
        "gcp_zone" = "us-west1-c"
    }
}

// IAM Workspace Data is used by ECS task definitions
data "terraform_remote_state" "presto_projects_iam" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/gke_iam"
  }
}