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
    value = "https://external-vault:8200"
  }
}

resource "kubernetes_service" "vault-hcp" {
  metadata {
    name = "external-vault"
    namespace = "default"
  }
  spec {
    port {
      port        = 8200
      target_port = 8200
    }
  }
}

resource "kubernetes_endpoints" "vault_hcp" {
  metadata {
    name = "external-vault"
    namespace = "default"
  }
  subset {
    address {
      ip = "54.202.212.187"
    }
    port {
      name     = "https"
      port     = 8200
      protocol = "TCP"
    }
  }
}