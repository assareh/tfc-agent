variable "tfc_agent_token" {
  type        = string
  description = "The preconfigured Terraform Cloud Agent token"
}
variable "gcp_zone" {
  type        = string
  default = "us-west1-c"
}
