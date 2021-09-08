variable "gcp_project" {
  description = "GCP Project ID can be sourced from Env.  Prefix with TF_VAR_"
}

variable "gcp_zone" {
  type        = string
  default = "us-west1-c"
}

variable "team2_agent_token" {
  type        = string
  description = "Terraform Cloud Agent Token"
  default = ""
}
variable "team1_agent_token" {
  type        = string
  description = "Terraform Cloud Agent Token"
  default = ""
}

