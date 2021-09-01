data "google_project" "project" {}

# Create Agent Pool - ServiceA
resource "tfe_agent_pool" "team-pool" {
  name         = "${var.team}_pool"
  organization = var.organization
}
resource "tfe_agent_token" "team-agent-token" {
  agent_pool_id = tfe_agent_pool.team-pool.id
  description   = "${var.team}-agent-token"
}

# Create Google service account - TeamA
resource "google_service_account" "team_gsa" {
  account_id   = "gsa-tfc-${var.team}"
  display_name = "Service Account For ${var.team} Workload Identity"
}

resource "google_project_iam_member" "team1-role" {
  role = "roles/compute.admin"
  #role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.team_gsa.email}"
}

# Enable GKE namespace/sa access to Google service account policy via Workload Identity
resource "google_project_iam_member" "workload_identity-role" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project}.svc.id.goog[tfc-team1/tfc-agent-dev]"
}