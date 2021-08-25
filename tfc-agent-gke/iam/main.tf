provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

data "google_project" "project" {}

resource "google_service_account" "tfc-agent" {
  project      = var.gcp_project
  display_name = "tfc-agent Service Account"
  account_id   = "tfc-agent"
}

# a role for terraform consumer to impersonate
# you'll need to customize IAM bindings to access resources as desired
resource "google_service_account" "terraform-dev-role" {
  project      = var.gcp_project
  display_name = "terraform-dev-role Service Account"
  account_id   = "terraform-dev-role"
}

resource "google_service_account_iam_binding" "terraform-dev-role" {
  service_account_id = google_service_account.terraform-dev-role.name
  role               = "roles/iam.serviceAccountTokenCreator"
  members = [
    "serviceAccount:${google_service_account.tfc-agent.email}",
  ]
}

resource "google_project_iam_binding" "container-admin" {
  project = var.gcp_project
  role    = "roles/container.admin"
  members = [
    "serviceAccount:${google_service_account.terraform-dev-role.email}",
  ]
}