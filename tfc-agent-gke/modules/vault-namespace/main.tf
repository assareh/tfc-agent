provider "vault" {
  # $VAULT_ADDR should be configured with the endpoint where to reach Vault API.
  # Or uncomment and update following line
  # address = "https://vault.prod.yet.org"
}

resource "vault_namespace" "ns" {
  path = var.namespace
}

output "id" {
  value = vault_namespace.ns.id
}
