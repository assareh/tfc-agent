variable "oauth_token_id" {}

variable "organization" {}

variable "workspacename" {}

variable "queue_all_runs" {default = true}

variable "auto_apply" {default = true}

variable "repobranch" {default = "master"}

variable "identifier" {}

variable "tfversion" {default = "0.11.14"}

variable "workingdir" {default = ""}

variable "global_remote_state" {default = ""}

variable "agent_pool_id" {default = ""}

variable "gcp_region" {default = ""}

variable "gcp_zone" {default = ""}

variable "gcp_project" {default = ""}

variable "gcp_credentials" {default = ""}

variable "aws_default_region" {default = ""}

variable "aws_secret_access_key" {default = ""}

variable "aws_access_key_id" {default = ""}

variable "arm_subscription_id" {default = ""}

variable "arm_client_secret" {default = ""}

variable "arm_tenant_id" {default = ""}

variable "arm_client_id" {default = ""}

# Terraform Variables
variable "tf_variables" {
  type = map
  default = {
    project_name = "ppresto_default"
  }
}

# Terraform HCL Variables
variable "tf_variables_sec" {
  type = map
  default = {}
}

# Env Variables
variable "env" {
  type = map
  default = {}
}
# Custom variables
variable "route53_zone_id" {default = ""}
variable "ssh_pri_key_data" {default = ""}
variable "consul_lic" {default = ""}
