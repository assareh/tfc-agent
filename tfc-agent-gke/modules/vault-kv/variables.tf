variable "kv_path" {
  description = "key value secret engine mount point"
  default = "kv"
}

variable "kv_secret_path" {
  description = "Secret path"
  default = "kv/demo"
}

variable "kv_secret_data" {
  description = "Secret content"
  default = "{\"username\": \"admin\", \"password\": \"password\", \"ttl\": \"20s\"}"
}