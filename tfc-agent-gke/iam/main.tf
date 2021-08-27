provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

data "google_project" "project" {}

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