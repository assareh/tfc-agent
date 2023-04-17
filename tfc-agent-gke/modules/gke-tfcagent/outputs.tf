output "gke_namespace" {
  value = var.kubernetes_namespace
}

output "gke_deployment" {
  value = kubernetes_deployment.tfc_cloud_agent
}