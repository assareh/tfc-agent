// Workspace Data
data "terraform_remote_state" "gke" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/gke"
  }
}
data "terraform_remote_state" "gke" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/iam"
  }
}
data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = var.gcp_zone
}

data "google_secret_manager_secret_version" "serviceA-agent-token" {
  secret   = "serviceA-agent-token"
}
output "serviceA-agent-token" {
  value = data.google_secret_manager_secret_version.serviceA-agent-token.secret_data
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
  source = "git::https://github.com/cloudposse/terraform-kubernetes-tfc-cloud-agent.git?ref=tags/0.3.0"
  context = module.this.context
  replicas = 2
  #tfc_agent_token = data.google_secret_manager_secret_version.serviceA-agent-token.secret_data
  tfc_agent_token = data.terraform_remote_state.iam.outputs.serviceA-agent-token
  namespace_creation_enabled = true
  kubernetes_namespace       = "tfc-agent"
  service_account_annotations = {
    "iam.gke.io/gcp-service-account" = "workload-identity-tutorial@${var.gcp_project}.iam.gserviceaccount.com",
  }
}