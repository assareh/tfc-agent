module "gke_tfcagents" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "gke_tfcagents"
    workingdir = "tfc-agent-gke/gke_tfcagents"
    tfversion = "0.13.6"
    repobranch = "gke3"
    #Add /Repo_Name after org
    identifier = "${var.repo_org}/tfc-agent"
    oauth_token_id = "${var.oauth_token_id}"
    gcp_credentials = "${var.gcp_credentials}"
    gcp_region      = "${var.gcp_region}"
    gcp_project     = "${var.gcp_project}"
    gcp_zone        = "${var.gcp_zone}"
    tf_variables = {
        "prefix" = "presto"
        "gcp_project" = var.gcp_project
        "gcp_region" = "us-west1"
        "gcp_zone" = "us-west1-c"
        "namespace" = "serviceA"
        "stage" = "deploy"
        "name" = "serviceA"
        "environment" = "dev"
        "token_tmp_out" = tfe_agent_token.serviceA-token.token
    }
       tf_variables_sec = {
        "tfc_agent_token" = tfe_agent_token.serviceA-token.token
    }
}

# ServiceA Agent Pool
resource "tfe_agent_pool" "serviceA" {
  name         = "tfc-agent-pool-serviceA"
  organization = var.organization
}
resource "tfe_agent_token" "serviceA-token" {
  agent_pool_id = tfe_agent_pool.serviceA.id
  description   = "tfc-agent-serviceA-token"
}