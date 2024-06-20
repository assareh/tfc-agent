variable "gcp_project" {
  description = "GCP Project ID can be sourced from Env.  Prefix with TF_VAR_"
}

variable "organization" { default = "presto-projects" }

variable "gcp_zone" {
  type        = string
  default = "us-west1-c"
}

variable "service_account_name" {
  type        = string
  default     = null
  description = "service account name"
}
variable "deployment_name" {
  type        = string
  default     = null
  description = "Override the deployment name in Kubernetes"
}

variable "kubernetes_namespace" {
  type        = string
  default     = null
  description = "Kubernetes namespace override"
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Number of replicas in the Kubernetes deployment"
}

variable "deployment_annotations" {
  type        = map
  default     = {}
  description = "Annotations to add to the Kubernetes deployment"
  /*  HCP Vault Example to pass credentials to tfc-agent pod
  deployment_annotations = {
    "vault.hashicorp.com/agent-inject" = "true"
    "vault.hashicorp.com/namespace" = "admin/"
    "vault.hashicorp.com/role" = "devweb-app"
    "vault.hashicorp.com/tls-skip-verify": "true"
    "vault.hashicorp.com/log-level" = "debug"
    "vault.hashicorp.com/agent-inject-secret-credentials.txt" = "secret/data/devwebapp/config"
  }
  */
}

variable "service_account_annotations" {
  type        = map
  default     = {}
  description = "Annotations to add to the Kubernetes service account"
}

variable "agent_image" {
  type        = string
  default     = "hashicorp/tfc-agent:latest"
  description = "Name and tag of Terraform Cloud Agent docker image"
}

variable "agent_cli_args" {
  type        = list
  default     = []
  description = "Extra command line arguments to pass to tfc-agent"
}

variable "agent_envs" {
  type        = map
  default     = {}
  description = "A map of any extra environment variables to pass to the TFC agent"
}

variable "agentpool_tokens" {
  #type        = string
  #default     = ""
  description = <<-EOF
    The agent token to use when making requests to the Terraform Cloud API.
    This token must be obtained from the API or UI.  It is recommended to use
    the environment variable whenever possible for configuring this setting due
    to the sensitive nature of API tokens.
  EOF
}

variable "tfc_agent_log_level" {
  type        = string
  default     = "info"
  description = <<-EOF
    The log verbosity expressed as a level string. Level options include
    "trace", "debug", "info", "warn", and "error"
  EOF
}

variable "tfc_agent_data_dir" {
  type        = string
  default     = null
  description = <<-EOF
    The path to a directory to store all agent-related data, including
    Terraform configurations, cached Terraform release archives, etc. It is
    important to ensure that the given directory is backed by plentiful
    storage.
  EOF
}

variable "tfc_agent_single" {
  type        = bool
  default     = false
  description = <<-EOF
    Enable single mode. This causes the agent to handle at most one job and
    immediately exit thereafter. Useful for running agents as ephemeral
    containers, VMs, or other isolated contexts with a higher-level scheduler
    or process supervisor.
  EOF
}

variable "tfc_agent_disable_update" {
  type        = bool
  default     = false
  description = "Disable automatic core updates."
}

variable "tfc_address" {
  type        = string
  default     = "https://app.terraform.io"
  description = "The HTTP or HTTPS address of the Terraform Cloud API."
}

variable "resource_limits_cpu" {
  type        = string
  default     = "1"
  description = "Kubernetes deployment resource hard CPU limit"
}

variable "resource_limits_memory" {
  type        = string
  default     = "512Mi"
  description = "Kubernetes deployment resource hard memory limit"
}

variable "resource_requests_cpu" {
  type        = string
  default     = "250m"
  description = "Kubernetes deployment resource CPU requests"
}

variable "resource_requests_memory" {
  type        = string
  default     = "50Mi"
  description = "Kubernetes deployment resource memory requests"
}

variable "tags" {
  type        = map(string)
  default     = {
    "Environment" = "dev"
    "Name" = "tfc-team-dev"
    "Namespace" = "tfc-team"
  }
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}