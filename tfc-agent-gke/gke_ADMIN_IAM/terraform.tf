provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

provider "tfe" {
  hostname = var.tfe_hostname
  token = var.tfe_token
}

terraform {
  required_version = ">= 0.13.06"
  required_providers {
    google = {
      version = "~> 3.81"
    }
    tfe = {
      version = "~>0.25"
    }
  }
}
