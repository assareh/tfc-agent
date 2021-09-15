// Workspace Data
data "terraform_remote_state" "gke" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/gke_cluster"
  }
}

data "terraform_remote_state" "admin_tfcagents_iam" {
  backend = "remote"
  config = {
    hostname = "app.terraform.io"
    organization = "presto-projects"
    workspaces    = {
      name = "gke_ADMIN_IAM"
    }
  }
}

locals {
  teams = data.terraform_remote_state.admin_tfcagents_iam.outputs.team_iam_config
}
data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = var.gcp_zone
}

provider "kubernetes" {
  #version = "~> 1.12"
  load_config_file = false
  host = "https://${data.terraform_remote_state.gke.outputs.k8s_endpoint}"
  config_context = data.terraform_remote_state.gke.outputs.context
  token                  = data.google_client_config.default.access_token
  #client_certificate     = base64decode(data.terraform_remote_state.gke.outputs.k8s_master_auth_client_certificate)
  #client_key             = base64decode(data.terraform_remote_state.gke.outputs.k8s_master_auth_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.gke.outputs.k8s_master_auth_cluster_ca_certificate)
}

module "tfc_agent" {
  source = "../modules/gke-tfcagent"
  for_each = local.teams
  tags = {
    "Environment" = local.teams[each.key].env
    "Name" = local.teams[each.key].k8s_sa
    "Namespace" = local.teams[each.key].namespace
  }
  replicas = 2
  deployment_name = local.teams[each.key].k8s_sa
  kubernetes_namespace       = local.teams[each.key].namespace
  service_account_name = local.teams[each.key].k8s_sa
  service_account_annotations = {
    "iam.gke.io/gcp-service-account" = "${local.teams[each.key].gsa}@${var.gcp_project}.iam.gserviceaccount.com",
  }
  tfc_agent_token = var.team1_agent_token
  resource_limits_memory = "128Mi"
  resource_limits_cpu = ".5"
}