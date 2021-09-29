# GKE Default SA with minimal permissions
resource "google_service_account" "gke" {
  account_id   = "${var.organization}-gke-sa-default"
  display_name = "GKE Default Service Account"
}

# Bootstrap new teams with TFCB Workspace + Agentpool, and GSA with approved roles. tfc-agent on GKE will use GSA roles.
module "iam-team-setup" {
  source         = "../modules/iam-team-setup"
  for_each      = local.iam_teams
  team          = local.iam_teams[each.key]
  #prefix        = "${var.prefix}-${each.key}"
  prefix        = var.organization
  organization  = var.organization
  tfe_token     = var.tfe_token
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_zone    = var.gcp_zone
}