variable "kubernetes_host" {
  description = "Kubernetes API endpoint"
}

variable "kubernetes_namespace" {
  description = "Kubernetes Namespace"
  default = "default"
}

variable "kubernetes_sa" {
  description = "Kubernetes Service Account"
  default = "default"
}

variable "kubernetes_ca_cert" {
  description = "Kubernetes CA"
}

variable "token_reviewer_jwt" {
  description = "Kubernetes Auth"
}

variable "k8s_role" {
  description = "Kubernetes Vault Auth role name"
  default = "k8s"
}

variable "k8s_path" {
  description = "k8s auth backend mount point"
  default = "k8s"
}

variable "policy_name" {
  description = "Name of the policy to be linked to"
  default = "k8s"
}