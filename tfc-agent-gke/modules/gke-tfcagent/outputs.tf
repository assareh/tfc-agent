output "gke_sa" {
  value = kubernetes_service_account.service_account
}
output "gke_deployment" {
  value = kubernetes_deployment.tfc_cloud_agent
}