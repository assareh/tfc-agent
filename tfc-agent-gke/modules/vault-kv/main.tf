# mounting kv secret engine
resource "vault_mount" "kv" {
  path        = var.kv_path
  type        = "kv-v2"
  description = "kv secret engine managed by Terraform"
}

resource "null_resource" "kv-v2-sleepfix" {

  depends_on = [vault_mount.kv]

  provisioner "local-exec" {
    command = "sleep 20"
  }
}

# storing secret
resource "vault_generic_secret" "secret" {
  path = var.kv_secret_path
  data_json = var.kv_secret_data

  depends_on = [null_resource.kv-v2-sleepfix]
}