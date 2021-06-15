provider "google" {
  alias  = "tokengen"
  scopes = ["cloud-platform", "userinfo-email"]
}

data "google_service_account_access_token" "default" {
  provider               = google.tokengen
  target_service_account = var.dev_role_sa
  lifetime               = "600s"
  scopes                 = ["cloud-platform", "userinfo-email"]
}

data "google_client_openid_userinfo" "source" {
  provider = google.tokengen
}

provider "google" {
  access_token = data.google_service_account_access_token.default.access_token
  project      = var.gcp_project
  region       = var.gcp_region
}

data "google_client_openid_userinfo" "target" {}

resource "google_compute_instance" "this" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.gcp_zone
  labels       = var.labels

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "default"

    access_config {}
  }
}
