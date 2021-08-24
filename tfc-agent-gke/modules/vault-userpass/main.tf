resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "u1" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/${var.username}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["superuser"],
  "password": "${var.password}"
}
EOT
}

resource "vault_generic_endpoint" "u1_token" {
  depends_on     = [vault_generic_endpoint.u1]
  path           = "auth/userpass/login/${var.username}"
  disable_read   = true
  disable_delete = true

  data_json = <<EOT
{
  "password": "${var.password}"
}
EOT
}

resource "vault_generic_endpoint" "u1_entity" {
  depends_on           = [vault_generic_endpoint.u1_token]
  disable_read         = true
  disable_delete       = true
  path                 = "identity/lookup/entity"
  ignore_absent_fields = true
  write_fields         = ["id"]

  data_json = <<EOT
{
  "alias_name": "${var.username}",
  "alias_mount_accessor": "${vault_auth_backend.userpass.accessor}"
}
EOT
}

output "u1_id" {
  value = vault_generic_endpoint.u1_entity.write_data["id"]
}