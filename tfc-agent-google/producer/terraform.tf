terraform {
  required_version = ">= 0.12.31"
  required_providers {
    google = {
      version = "~> 3.69"
    }
    random = {
      version = ">= 2.0"
    }
  }
}