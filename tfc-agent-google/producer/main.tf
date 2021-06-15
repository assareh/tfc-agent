provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

data "google_project" "project" {
}

resource "google_service_account" "tfc-agent" {
  project      = var.gcp_project
  display_name = "tfc-agent Service Account"
  account_id   = "tfc-agent"
}

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

resource "google_project_iam_binding" "compute-admin" {
  project = var.gcp_project
  role    = "roles/compute.admin"
  members = [
    "serviceAccount:${google_service_account.terraform-dev-role.email}",
  ]
}

resource "google_compute_instance" "tfc-agent" {
  count        = 1
  name         = "${var.prefix}-${count.index}"
  machine_type = var.machine_type
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable-89-16108-403-26"
    }
  }

  labels = {
    container-vm = "cos-stable-89-16108-403-26"
  }

  metadata = {
    google-logging-enabled    = "true"
    gce-container-declaration = "spec:\n  containers:\n    - name: ${var.prefix}-${count.index}\n      image: 'docker.io/hashicorp/tfc-agent:latest'\n      env:\n        - name: TFC_AGENT_TOKEN\n          value: ${var.tfc_agent_token}\n        - name: TFC_AGENT_SINGLE\n          value: true\n      stdin: false\n      tty: false\n  restartPolicy: Always\n\n# This container declaration format is not public API and may change without notice. Please\n# use gcloud command-line tool or Google Cloud Console to run Containers on Google Compute Engine."
  }

  network_interface {
    network = "default"

    access_config {}
  }

  service_account {
    email = google_service_account.tfc-agent.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/userinfo.email",
    ]
  }
}