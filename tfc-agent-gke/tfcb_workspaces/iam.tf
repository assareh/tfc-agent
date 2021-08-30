data "google_project" "project" {}

# Create Agent Pool - ServiceA
resource "tfe_agent_pool" "pool-serviceA" {
  name         = "serviceA_pool"
  organization = var.organization
}
resource "tfe_agent_token" "serviceA-agent-token" {
  agent_pool_id = tfe_agent_pool.pool-serviceA.id
  description   = "serviceA-agent-token"
}

# Create Google service account - ServiceA
resource "google_service_account" "gsa_team_serviceA" {
  account_id   = "teamserviceA"
  display_name = "Service Account For Workload Identity"
}

resource "google_project_iam_member" "storage-role" {
  role = "roles/compute.admin"
  #role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.gsa_team_serviceA.email}"
}

# Enable GKE namespace/sa access to Google service account policy via Workload Identity
resource "google_project_iam_member" "workload_identity-role" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project}.svc.id.goog[tfc-agent/servicea-dev-deploy-servicea]"
}