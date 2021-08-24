module "gcp_gke_tfcagents" {
    source = "../modules/workspace"
    organization = "${var.organization}"
    queue_all_runs = false
    auto_apply = true
    workspacename = "gcp_gke_tfcagents"
    workingdir = "tfc-agent-gke/gke"
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
        "gke_num_nodes" = 3
        "ip_cidr_range" = "10.10.0.0/24"
        "k8sloadconfig" = true
    }
       tf_variables_sec = {
        "tfe_token"      = var.tfe_token
    }
}