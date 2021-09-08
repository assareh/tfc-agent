// Workspace Data
data "terraform_remote_state" "gke" {
  backend = "atlas"
  config = {
    address = "https://app.terraform.io"
    name    = "presto-projects/gke"
  }
}

data "google_client_config" "default" {}

data "google_container_cluster" "my_cluster" {
  name = data.terraform_remote_state.gke.outputs.kubernetes_cluster_name
  location = var.gcp_zone
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.terraform_remote_state.gke.outputs.k8s_endpoint}"
    cluster_ca_certificate = base64decode(data.terraform_remote_state.gke.outputs.k8s_master_auth_cluster_ca_certificate)
    config_context         = data.terraform_remote_state.gke.outputs.context
    token                  = data.google_client_config.default.access_token
  }
}

resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "0.15.0"

  #values = [
  #  file("${path.module}/override-values.yaml")
  #]
  set {
    name  = "server.dev.enabled"
    value = "true"
  }

  set_sensitive {
    name  = "tfc.token"
    value = var.tfc_app_token
  }
}
