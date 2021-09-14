  
resource "kubernetes_service_account" "service_account" {
  metadata {
    name        = var.service_account_name
    namespace   = kubernetes_namespace
    annotations = var.service_account_annotations
  }
}

resource "kubernetes_secret" "secret" {
  metadata {
      name      = var.deployment_name
      namespace = var.kubernetes_namespace
  }

  data = {
    token = var.tfc_agent_token
  }
}
resource "kubernetes_deployment" "tfc_cloud_agent" {
  metadata {
    name      = var.deployment_name
    namespace = var.kubernetes_namespace
    labels    = var.tags
  }
  spec {
    selector {
      match_labels = var.tags
    }
    replicas = var.replicas

    template {
      metadata {
        namespace   = var.kubernetes_namespace
        labels      = var.tags
        annotations = {}
      }
      spec {
        service_account_name            = var.service_account_name
        automount_service_account_token = true
        container {
          image = var.agent_image
          name  = "tfc-agent"
          args  = var.agent_cli_args
          env {
            name = "TFC_AGENT_TOKEN"
            value_from {
              secret_key_ref {
                key  = "token"
                name = var.deployment_name
              }
            }
          }
          env {
            name  = "TFC_AGENT_NAME"
            value = "tfc-agent-3"
          }
          env {
            name  = "TFC_AGENT_LOG_LEVEL"
            value = "debug"
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