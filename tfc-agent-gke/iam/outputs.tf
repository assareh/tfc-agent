output "gcp_project" {
  value = data.google_project.project.id
}

output "instance_names" {
  value = google_compute_instance.tfc-agent.*.name
}

output "k8s_cluster_sa_email" {
  value = google_service_account.cluster-serviceaccount.email
}
