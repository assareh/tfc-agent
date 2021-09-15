output "kubernetes_cluster_name" {
  value       = module.gcp-vpc-gke.kubernetes_cluster_name
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
  value = module.gcp-vpc-gke.k8s_endpoint
}

output "k8s_master_version" {
  value = module.gcp-vpc-gke.k8s_master_version
}

output "k8s_instance_group_urls" {
  value = module.gcp-vpc-gke.k8s_instance_group_urls
}

#output "k8s_master_auth_client_certificate" {
#  value = module.gcp-vpc-gke.k8s_master_auth_client_certificate
#}

#output "k8s_master_auth_client_key" {
#  value = module.gcp-vpc-gke.k8s_master_auth_client_key
#}

output "k8s_master_auth_cluster_ca_certificate" {
  value = module.gcp-vpc-gke.k8s_master_auth_cluster_ca_certificate
}

#output "crypto_key_id" {
#  value = "${module.gcp-gke-kms.location}/${module.gcp-gke-kms.key_ring}/${module.gcp-gke-kms.crypto_key}"
#}

output "gke_namespace" {
  value = var.gke_namespace
}

# Kubernetes context.  Update gcp_zone to region depending on how you build your cluster.
output "context" {
  value = "gke_${var.gcp_project}_${var.gcp_zone}_${var.prefix}"
}

output "gcp_project" {
  value = var.gcp_project
}

output "vault_helm" {
  value = helm_release.vault.metadata
}