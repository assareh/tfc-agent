output "VAULT_ADDR" {
    value = "https://${data.terraform_remote_state.gke.outputs.k8s_endpoint}:8200"
}