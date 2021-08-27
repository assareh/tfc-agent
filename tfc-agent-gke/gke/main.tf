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
  #gke_service_account_email = data.terraform_remote_state.iam.outputs.k8s_cluster_sa_email
  #gke_namespace  = var.gke_namespace
}