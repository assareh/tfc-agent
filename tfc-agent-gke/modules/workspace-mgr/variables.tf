variable "organization" {}

variable "workspacename" {}
variable "queue_all_runs" {default = true}
variable "auto_apply" {default = true}
variable "tfversion" {default = "0.11.14"}
variable "workingdir" {default = ""}
variable "global_remote_state" {default = ""}

variable "oauth_token_id" {}
variable "repo_branch" { default = "main"}
variable "identifier" {}
variable "agent_pool_id" {default = ""}

# Terraform Variables
variable "tf_variables" {
  type = map
  default = {
    prefix = "myproject"
  }
}
# Terraform Variables
variable "tf_variables_map" {
  default = {
    labels = {"prefix" = "myproject"}
  }
}

# Terraform HCL Variables
variable "tf_variables_sec" {
  type = map
  default = {}
}

# Env Variables
variable "env_variables" {
  type = map
  default = {}
}

# Env Variables
variable "env_variables_sec" {
  type = map
  default = {}
}

# IAM Teams Map
#variable "teams_config" {
#  type = map
#  default = {}
#}