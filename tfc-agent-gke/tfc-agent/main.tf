// Workspace Data
data "terraform_remote_state" "gke" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/gke_cluster"
  }
}

provider "kubernetes" {
  #version = "~> 1.12"
  load_config_file = false
  host = "https://${data.terraform_remote_state.gke.outputs.k8s_endpoint}"
  config_context = data.terraform_remote_state.gke.outputs.context
  username = ""
  password = ""
  client_certificate     = "${base64decode(data.terraform_remote_state.gke.outputs.k8s_master_auth_client_certificate)}"
  client_key             = "${base64decode(data.terraform_remote_state.gke.outputs.k8s_master_auth_client_key)}"
  cluster_ca_certificate = "${base64decode(data.terraform_remote_state.gke.outputs.k8s_master_auth_cluster_ca_certificate)}"
}

module "tfc_agent" {
  source = "git::https://github.com/cloudposse/terraform-kubernetes-tfc-cloud-agent.git?ref=tags/0.3.0"
  context = module.this.context

  tfc_agent_token = var.tfc_agent_token

  namespace_creation_enabled = true
  kubernetes_namespace       = "tfc-agent"
}
