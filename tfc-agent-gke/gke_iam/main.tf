provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

provider "tfe" {
  #version = "<= 0.7.0"
  token = var.tfe_token
}

data "google_project" "project" {}

# ServiceA Agent Pool
resource "tfe_agent_pool" "pool-serviceA" {
  name         = "serviceA_pool"
  organization = var.organization
}
resource "tfe_agent_token" "serviceA-agent-token" {
  agent_pool_id = tfe_agent_pool.pool-serviceA.id
  description   = "serviceA-agent-token"
}

# service account
resource "google_service_account" "workload-identity-user-sa" {
  account_id   = "workload-identity-tutorial"
  display_name = "Service Account For Workload Identity"
}

resource "google_project_iam_member" "storage-role" {
  # role = "roles/compute.admin"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.workload-identity-user-sa.email}"
}
resource "google_project_iam_member" "workload_identity-role" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project}.svc.id.goog[tfc-agent/servicea-dev-deploy-servicea]"
}