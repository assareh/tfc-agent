# GCP Default SA
resource "google_service_account" "gke" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

output "gke_service_account_email" {
  value = google_service_account.gke.email
}