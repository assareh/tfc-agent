// Workspace Data
#data "terraform_remote_state" "iam" {
#  backend = "atlas"
#  config = {
#    address = "https://app.terraform.io"
#    name    = "presto-projects/iam"
#  }
#}


module "gcp-vpc-gke" {
  source         = "../modules/gcp-vpc-gke"
  prefix        = var.prefix
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
  ip_cidr_range = var.ip_cidr_range
  gke_num_nodes = var.gke_num_nodes
  k8sloadconfig = false
  gke_service_account_email = var.gke_service_account_email
  #gke_namespace  = var.gke_namespace
}

// Install Vault injector
data "google_client_config" "default" {}
provider "helm" {
  kubernetes {
    host                   = "https://${module.gcp-vpc-gke.k8s_endpoint}"
    cluster_ca_certificate = base64decode(module.gcp-vpc-gke.k8s_master_auth_cluster_ca_certificate)
    #config_context         = module.gcp-vpc-gke.context
    token                  = data.google_client_config.default.access_token
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.15.0"
  set {
    name  = "injector.externalVaultAddr"
    value = "http://external-vault:8200"
  }
}