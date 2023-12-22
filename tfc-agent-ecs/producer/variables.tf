variable "api_gateway_enabled" {
  description = "Whether to deploy an API gateway for the Lambda"
  # when to use function url vs api gateway
  # https://aws.amazon.com/blogs/aws/announcing-aws-lambda-function-urls-built-in-https-endpoints-for-single-function-microservices/
  default = false
}

variable "app_version" {
  description = "Version of lambda to deploy"
  default     = "1.0.0"
}

variable "desired_count" {
  description = "Desired count of tfc-agents to run. Suggested 2 * run concurrency. Default TFCB concurrency is 2. May want to set this lower as desired if using lamdba autoscaling."
  default     = 4
}

variable "ip_cidr_vpc" {
  description = "IP CIDR for VPC"
  default     = "172.31.0.0/16"
}

variable "ip_cidr_agent_subnet" {
  description = "IP CIDR for tfc-agent subnet"
  default     = "172.31.16.0/24"
}

variable "max_count" {
  description = "Maximum count of tfc-agents to run. Suggested 2 * run concurrency. Default TFCB concurrency is 2."
  default     = 4
}

variable "notification_token" {
  description = "Used to generate the HMAC on the notification request. Read more in the documentation."
  default     = "SuperSecret!!"
}

variable "prefix" {
  description = "Name prefix to add to the resources"
}

variable "region" {
  description = "The region where the resources are created."
  default     = "us-west-2"
}

variable "task_cpu" {
  description = "The total number of cpu units used by the task."
  default     = 4096
}

variable "task_mem" {
  description = "The total amount (in MiB) of memory used by the task."
  default     = 8192
}

variable "task_def_cpu" {
  description = "The number of cpu units used by the task at the container definition level."
  default     = 1024
}

variable "task_def_mem" {
  description = "The amount (in MiB) of memory used by the task at the container definition level."
  default     = 2048
}

variable "tfc_agent_token" {
  description = "Terraform Cloud agent token. (mark as sensitive) (TFC Organization Settings >> Agents)"
}

// OPTIONAL Tags
variable "ttl" {
  description = "OPTIONAL for Cloud Custodian; value of ttl tag on cloud resources"
  default     = "1"
}

// OPTIONAL Tags
locals {
  common_tags = {
    owner              = "your-name-here"
    se-region          = "your-region-here"
    purpose            = "Default state is dormant with no active resources. Runs a Terraform Cloud Agent when a run is queued."
    ttl                = var.ttl # hours
    terraform          = "true"  # true/false
    hc-internet-facing = "false" # true/false
  }
}
