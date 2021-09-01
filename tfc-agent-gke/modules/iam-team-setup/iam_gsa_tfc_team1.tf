data "google_project" "project" {}

# Create Agent Pool - ServiceA
resource "tfe_agent_pool" "pool-team1" {
  name         = "team1_pool"
  organization = var.organization
}
resource "tfe_agent_token" "team1-agent-token" {
  agent_pool_id = tfe_agent_pool.pool-team1.id
  description   = "team1-agent-token"
}

# Create Google service account - TeamA
resource "google_service_account" "gsa_team1" {
  account_id   = "gsa-tfc-team1"
  display_name = "Service Account For Workload Identity"
}

resource "google_project_iam_member" "team1-role" {
  role = "roles/compute.admin"
  #role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.gsa_team1.email}"
}

# Enable GKE namespace/sa access to Google service account policy via Workload Identity
resource "google_project_iam_member" "workload_identity-role" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project}.svc.id.goog[tfc-team1/tfc-agent-dev]"
}