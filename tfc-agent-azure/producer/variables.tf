variable "notification_token" {
  description = "Used to generate the HMAC on the notification request. Read more in the documentation."
  default     = "SuperSecret!!"
}

variable "resource_group_name" {
  description = "The name of an existing resource group where the containerized agents will be deployed."
}

variable "tfc_agent_token" {
  description = "HCP Terraform Agent token. (mark as sensitive) (HCP Terraform Organization Settings >> Agents)"
}
