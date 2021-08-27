output "gcp_project" {
  value = data.google_project.project.id
}

output "k8s_cluster_sa_email" {
  value = google_service_account.cluster-serviceaccount.email
}
