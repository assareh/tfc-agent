# GKE Default SA with minimal permissions
resource "google_service_account" "gke" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

#output "gke_service_account_email" {
#  value = google_service_account.gke.email
#}

# Bootstrap new teams with TFCB Workspace + Agentpool, and GSA with approved roles. tfc-agent on GKE will use GSA roles.
module "iam-team-setup" {
  source         = "../modules/iam-team-setup"
  for_each      = var.iam_teams
  team          = each.key
  team_roles    = flatten([ for role in each.value.roles: {"role" = role} ])
  prefix        = "${var.prefix}-${each.key}"
  tfe_token     = var.tfe_token
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
  iam_teams    = var.iam_teams
}