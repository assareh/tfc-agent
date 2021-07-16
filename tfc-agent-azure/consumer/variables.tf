variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West US 2"
}

variable "password" {
  description = "The admin password for the instance (subject to complexity requirements)."
  default     = "SuperSecret!!"
}

variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
}

variable "subscription_id" {
  description = "The subscription id in which all resources in this example should be created."
}

variable "username" {
  description = "The admin username for the instance."
  default     = "admin"
}
