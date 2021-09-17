# GKE Default SA with minimal permissions
resource "google_service_account" "gke" {
  account_id   = "iam-gke-sa-default"
  display_name = "GKE Default Service Account"
}

# Bootstrap new teams with TFCB Workspace + Agentpool, and GSA with approved roles. tfc-agent on GKE will use GSA roles.
module "iam-team-setup" {
  source         = "../modules/iam-team-setup"
  for_each      = var.iam_teams
  team          = var.iam_teams[each.key]
  prefix        = "${var.prefix}-${each.key}"
  tfe_token     = var.tfe_token
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
}