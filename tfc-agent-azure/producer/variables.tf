variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which the containerized agents will be deployed"
}

variable "tfc_agent_token" {
  description = "Terraform Cloud agent token. (mark as sensitive) (TFC Organization Settings >> Agents)"
}
