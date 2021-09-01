terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      version = "~> 3.81"
    }
    tfe = {
      version = "~>0.25"
    }
  }
}
