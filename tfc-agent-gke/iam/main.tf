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

# Create a secret for local-admin-password
resource "google_secret_manager_secret" "serviceA-agent-token" {
  #provider = google-beta
  
  secret_id = "serviceA-agent-token"
  replication {
    automatic = true
  }
}
# Add the secret data for local-admin-password secret
resource "google_secret_manager_secret_version" "serviceA-agent-token" {
  secret = google_secret_manager_secret.serviceA-agent-token.id
  secret_data = tfe_agent_token.serviceA-agent-token.token
}

data "google_secret_manager_secret_version" "serviceA-agent-token" {
  secret   = google_secret_manager_secret.serviceA-agent-token.id
}
output "serviceA-agent-token" {
  value = data.google_secret_manager_secret_version.serviceA-agent-token.secret_data
}

#k8s cluster account
resource "google_service_account" "cluster-serviceaccount" {
  account_id   = "cluster-serviceaccount"
  display_name = "Service Account For Terraform To Make GKE Cluster"
}

# service account
resource "google_service_account" "workload-identity-user-sa" {
  account_id   = "workload-identity-tutorial"
  display_name = "Service Account For Workload Identity"
}
resource "google_project_iam_member" "storage-role" {
  role = "roles/storage.admin"
  # role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.workload-identity-user-sa.email}"
}
resource "google_project_iam_member" "workload_identity-role" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project}.svc.id.goog[tfc-agent/servicea-dev-deploy-servicea]"
}