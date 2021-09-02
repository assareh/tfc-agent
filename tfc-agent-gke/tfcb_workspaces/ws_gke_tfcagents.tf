module "gke_tfcagents" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "gke_tfcagents"
    workingdir = "tfc-agent-gke/gke_tfcagents"
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
        "namespace" = "tfc-agent"
        "environment" = "dev"
        for t in sort(keys(var.iam_teams)) :
            t => module.iam-team-setup[t].agent_token
    }
    #tf_variables_sec = {
    #    "tfc_agent_token" = module.iam-team-setup.agent_token
    #}
    #tf_variables_sec = { 
    #    for t in sort(keys(var.iam_teams)) :
    #        t => module.iam-team-setup[t].agent_token
    #}
}