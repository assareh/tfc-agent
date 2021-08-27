variable "dev_role_sa" {
  description = "Service account email of the dev role to be impersonated (this was created in the producer workspace)"
}

variable "gcp_project" {
  description = "GCP project name"
}

variable "gcp_region" {
  description = "GCP region, e.g. us-east1"
  default     = "us-west1"
}

variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-a"
  default     = "us-west1-b"
}

variable "image" {
  description = "image to build instance from"
  default     = "debian-cloud/debian-9"
}

variable "instance_name" {
  description = "GCP instance name"
  default     = "created-with-terraform-cloud-agent"
}

variable "labels" {
  description = "descriptive labels for instances deployed"
  default = {
    "name" : "demo-compute-instance",
    "owner" : "your-name",
    "ttl" : "1",
  }
}

variable "machine_type" {
  description = "GCP machine type"
  default     = "f1-micro"
}
