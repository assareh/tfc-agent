// Workspace Data
#data "terraform_remote_state" "iam" {
#  backend = "atlas"
#  config = {
#    address = "https://app.terraform.io"
#    name    = "presto-projects/iam"
#  }
#}

locals {
  gsa_gke_email = var.gsa_gke_email!="" ? var.gsa_gke_email : "${var.project}-compute@developer.gserviceaccount.com"
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
  #gke_namespace  = var.gke_namespace
}