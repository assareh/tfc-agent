resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = var.k8s_path
}

resource "vault_kubernetes_auth_backend_config" "k8s_auth" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = var.kubernetes_host
  kubernetes_ca_cert = var.kubernetes_ca_cert
  token_reviewer_jwt = var.token_reviewer_jwt
}

resource "vault_kubernetes_auth_backend_role" "k8s_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = var.k8s_role
  bound_service_account_names      = [var.kubernetes_sa]
  bound_service_account_namespaces = [var.kubernetes_namespace]
  token_ttl                        = 3600
  token_policies                   = ["default", var.policy_name]
}