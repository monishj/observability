resource "kubernetes_service_account" "fluentd" {
  metadata {
    name      = "fluentd"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = format("arn:aws:iam::%s:role/ApplicationLog", var.AWS_account_id)
    }
  }
  automount_service_account_token = true
  depends_on                      = [kubernetes_namespace.centralized-observability-logs]
}

resource "kubernetes_cluster_role" "observability-fluentd" {
  metadata {
    name = "observability-fluentd"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "pods/logs"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "observability-fluentd-binding" {
  metadata {
    name = "observability-fluentd-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "observability-fluentd"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "fluentd"
    namespace = var.namespace
  }
}

resource "kubernetes_config_map" "fluentd-config" {
  metadata {
    name      = format("fluentd-config-%s", filesha1("${path.module}/configmaps/fluent.conf"))
    namespace = var.namespace
    labels = {
      k8s-app = "fluentd-s3"
    }
  }
  data = {
    "fluent.conf"     = file("${path.module}/configmaps/fluent.conf")
    "systemd.conf"    = file("${path.module}/configmaps/systemd.conf")
    "kubernetes.conf" = file("${path.module}/configmaps/kubernetes.conf")
    "prometheus.conf" = file("${path.module}/configmaps/prometheus.conf")
    "host.conf"       = file("${path.module}/configmaps/host.conf")
  }
}

resource "kubernetes_daemon_set_v1" "fluentd-daemonset" {
  metadata {
    name      = "fluentd-daemonset"
    namespace = var.namespace
    labels = {
      k8s-app                         = "fluentd-s3"
      "kubernetes.io/cluster-service" = "true"
    }
  }
  spec {
    selector {
      match_labels = {
        k8s-app = "fluentd-s3"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app                         = "fluentd-s3"
          pipelineid                      = var.pipeline_label # TechDebt - failure due to limit of 63 chars
          "kubernetes.io/cluster-service" = "true"
        }
        annotations = {
          configmap-resource-version = kubernetes_config_map.fluentd-config.metadata[0].resource_version
        }
      }
      spec {
        service_account_name             = "fluentd"
        automount_service_account_token  = true
        termination_grace_period_seconds = 30
        toleration {
          effect   = "NoExecute"
          operator = "Exists"
        }
        toleration {
          effect   = "NoSchedule"
          operator = "Exists"
        }
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/arch"
                  operator = "In"
                  values   = ["amd64"]
                }
              }
            }
          }
        }
        security_context {
          fs_group = 1337
        }
        container {
          name  = "fluentd-s3"
          image = "registry-emea.app.corpintra.net/dockerhub/fluent/fluentd-kubernetes-daemonset:${local.fluentd-kubernetes-daemonset-image-tag}"
          env {
            name = "K8S_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name  = "REGION"
            value = var.region
          }
          env {
            name  = "BUCKET_NAME"
            value = format("%s-%s-%s-logbucket", var.team_name, var.account_env, var.AWS_account_id)
          }
          env {
            name  = "CLUSTER_NAME"
            value = var.team_name
          }
          env {
            name  = "ROLE_ARN"
            value = format("arn:aws:iam::%s:role/ApplicationLog", var.AWS_account_id)
          }
          port {
            container_port = 24231
            name           = "metrics"
          }
          resources {
            limits = {
              memory = "400Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }
          volume_mount {
            name       = "config-volume"
            mount_path = "/fluentd/etc"
          }
          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }
          volume_mount {
            name       = "containerlogdirectory"
            mount_path = "/var/log/containers"
            read_only  = true
          }
        }
        volume {
          name = "config-volume"
          config_map {
            name = kubernetes_config_map.fluentd-config.metadata[0].name
          }
        }
        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "containerlogdirectory"
          host_path {
            path = "/var/log/containers"
          }
        }
      }
    }
  }
}
