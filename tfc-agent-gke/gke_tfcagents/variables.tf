variable "gcp_project" {
  description = "GCP Project ID can be sourced from Env.  Prefix with TF_VAR_"
}

variable "gcp_zone" {
  type        = string
  default = "us-west1-c"
}

variable "tfc_agent_token" {
  type        = string
  description = "The preconfigured Terraform Cloud Agent token"
}