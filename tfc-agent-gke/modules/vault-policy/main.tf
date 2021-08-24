resource "vault_policy" "acl" {
  name = var.policy_name
  policy = var.policy_code
}