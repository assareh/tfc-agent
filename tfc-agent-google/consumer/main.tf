# this block is if you would like to show source identity as terraform output
# provider "google" {
#   alias  = "source"
#   scopes = ["cloud-platform", "userinfo-email"]
# }

# this block is if you would like to show source identity as terraform output
# data "google_client_openid_userinfo" "source" {
#   provider = google.source
# }

provider "google" {
  impersonate_service_account = var.dev_role_sa
  project                     = var.gcp_project
  region                      = var.gcp_region
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
