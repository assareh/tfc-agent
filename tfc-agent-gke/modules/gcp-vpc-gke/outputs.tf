output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "region" {
  value       = var.gcp_region
  description = "region"
}

output "zone" {
  value       = var.gcp_zone
  description = "zone"
}

output "k8s_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "k8s_master_version" {
  value = google_container_cluster.primary.master_version
}

output "k8s_instance_group_urls" {
  value = google_container_cluster.primary.instance_group_urls
}

output "k8s_master_auth_client_certificate" {
  value = google_container_cluster.primary.master_auth.0.client_certificate
}

output "k8s_master_auth_client_key" {
  value = google_container_cluster.primary.master_auth.0.client_key
}

output "k8s_master_auth_cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}

output "gke_namespace" {
  value = var.gke_namespace
}

