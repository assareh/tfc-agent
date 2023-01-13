variable "prefix" {
  description = "This prefix will be included in the name of some resources. Use your own name or any other short string here."
}

variable "gcp_project" {
  description = "GCP Project ID can be sourced from Env.  Prefix with TF_VAR_"
}

variable "gcp_region" {
  description = "GCP region"
  default     = "us-east1"
}
variable "gcp_zone" {
  description = "GCP zone will deploy a single master.  Use region instead for multi-master deployment (HA)"
  default     = "us-east1-c"
}
variable "cluster_version" {
  default = "1.20"
}

variable "ip_cidr_range" {
  default = "10.10.0.0/24"
}
  
variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "gke_num_nodes" {
  default     = 3
  description = "number of gke nodes"
}

variable "gke_namespace" {
  default     = "default"
  description = "Kubernetes Vault Namespace"
}
variable "gke_service_account_email" {
  default     = ""
  description = "Kubernetes Vault Namespace"
}


variable k8sloadconfig {
    default = ""
}