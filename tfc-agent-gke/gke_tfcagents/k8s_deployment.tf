locals {
  service_account_name = "tfc-team3"
  deployment_name = "tfc-team3"
  namespace = "default"
  tags = {}
  token = var.team1_agent_token
  service_account_annotations = {"iam.gke.io/gcp-service-account" = "gsa-tfc-team1@${var.gcp_project}.iam.gserviceaccount.com",}

}

variable "replicas" {default = 1}
variable "agent_image" {default = "hashicorp/tfc-agent:latest"}
variable "agent_cli_args" {default = []}

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

resource "kubernetes_service_account" "service_account" {

  metadata {
    name        = local.service_account_name
    namespace   = local.namespace
    annotations = local.service_account_annotations
  }
}

resource "kubernetes_deployment" "tfc_cloud_agent" {
  metadata {
    name      = local.deployment_name
    namespace = local.namespace
    labels    = local.tags
  }
  spec {
    selector {
      match_labels = local.tags
    }
    replicas = var.replicas

    template {
      metadata {
        namespace   = local.namespace
        labels      = local.tags
        annotations = {}
      }
      spec {
        service_account_name            = local.service_account_name
        automount_service_account_token = true
        container {
          image = var.agent_image
          name  = "tfc-agent"
          args  = var.agent_cli_args
          env {
            name = "TFC_AGENT_TOKEN"
            value = "local.token"
          }
          env {
            name  = "TFC_AGENT_NAME"
            value = "tfc-agent-3"
          }
          env {
            name  = "TFC_AGENT_LOG_LEVEL"
            value = "info"
          }
          env {
            name  = "TFC_AGENT_SINGLE"
            value = false
          }
          env {
            name  = "TFC_AGENT_DISABLE_UPDATE"
            value = false
          }
          env {
            name  = "TFC_ADDRESS"
            value = var.tfc_address
          }
          resources {
            limits {
              cpu    = var.resource_limits_cpu
              memory = var.resource_limits_memory
            }
            requests {
              cpu    = var.resource_requests_cpu
              memory = var.resource_requests_memory
            }
          }
        }
      }
    }
  }
}