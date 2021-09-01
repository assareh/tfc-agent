data "google_project" "project" {}

# Create Agent Pool - ServiceA
resource "tfe_agent_pool" "team_pool" {
  name         = "${var.team.name}_pool"
  organization = var.organization
}
resource "tfe_agent_token" "team_agent_token" {
  agent_pool_id = tfe_agent_pool.team_pool.id
  description   = "${var.team.name} agent token"
}

# Create Google service account - TeamA
resource "google_service_account" "team_gsa" {
  account_id   = "${var.team.gsa}"
  display_name = "Service Account For ${var.team.name} Workload Identity"
}

resource "google_project_iam_member" "role" {
  for_each = toset(var.team.roles)
  role = "roles/${each.value}"
  member = "serviceAccount:${google_service_account.team_gsa.email}"
}

# Enable GKE namespace/sa access to Google service account policy via Workload Identity
resource "google_project_iam_member" "workload_identity-role" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project}.svc.id.goog[${var.team.namespace}/${var.team.k8s_sa}]"
}