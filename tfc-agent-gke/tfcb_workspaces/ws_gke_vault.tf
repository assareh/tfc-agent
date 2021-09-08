module "gke_vault" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "gke_vault"
    workingdir = "tfc-agent-gke/gke_vault"
    tfversion = "0.13.6"
    repobranch = var.repo_branch
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
        "namespace" = "vault"
        "environment" = "dev"
    }

    tf_variables_sec = { 
        for t in sort(keys(var.iam_teams)) :
        "${t}_agent_token" => module.iam-team-setup[t].agent_token
    }
}
