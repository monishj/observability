resource "kubernetes_namespace" "centralized-observability-logs" {
  metadata {
    name = "centralized-observability-logs"
  }
}

resource "kubernetes_default_service_account" "logs" {
  metadata {
    namespace = kubernetes_namespace.centralized-observability-logs.metadata[0].name
  }
  automount_service_account_token = false
}
