provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

terraform {
  required_version = ">= 0.12"
}
