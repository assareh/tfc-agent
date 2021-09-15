// Workspace Data
data "terraform_remote_state" "admin_tfcagents_iam" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/admin_tfcagents_iam"
  }
}

locals {
  teams = data.terraform_remote_state.admin_tfcagents_iam.team_iam_config
}

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
    token                  = data.google_client_config.default.access_token
  }
}

// Kubernetes resources
provider "kubernetes" {
  #version = "~> 1.12"
  host                   = "https://${module.gcp-vpc-gke.k8s_endpoint}"
  cluster_ca_certificate = base64decode(module.gcp-vpc-gke.k8s_master_auth_cluster_ca_certificate)
  token                  = data.google_client_config.default.access_token
  #config_context = data.terraform_remote_state.gke.outputs.context
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.15.0"
  set {
    name  = "injector.externalVaultAddr"
    value = "https://hcp-vault-cluster.vault.11eb13d3-0dd1-af4a-9eb3-0242ac110018.aws.hashicorp.cloud:8200"
  }
}

resource "kubernetes_namespace" "namespace" {
  for_each = local.teams
  metadata {
    name = local.teams[each.key].namespace
  }
}

resource "kubernetes_service_account" "service_account" {
  for_each = local.teams

  metadata {
    name        = local.teams[each.key].k8s_sa
    namespace   = local.teams[each.key].namespace
    annotations = {"iam.gke.io/gcp-service-account" = "${local.teams[each.key].gsa}@${var.gcp_project}.iam.gserviceaccount.com",}
  }
}