resource "kubernetes_service" "logstash" {
  metadata {
    name      = "${var.app-name}-${var.team_name}-${var.env}"
    namespace = var.logstash_namespace
  }
  spec {
    selector = {
      app = "${var.app-name}-${var.team_name}-${var.env}"
    }
    port {
      port        = 5044
      target_port = 5044
      name        = "beats"
    }
    port {
      port        = 9600
      target_port = 9600
      name        = "api"
    }
  }
}

resource "kubernetes_stateful_set" "logstash" {

  depends_on = [kubernetes_service.logstash]

  metadata {
    name = "${var.app-name}-${var.team_name}-${var.env}"
    labels = {
      app = "logstash"
    }
    namespace = var.logstash_namespace
  }

  spec {
    service_name = "${var.app-name}-${var.team_name}-${var.env}"
    replicas     = 1

    selector {
      match_labels = {
        app = "logstash"
      }
    }

    template {
      metadata {
        labels = {
          app = "logstash"
        }
        annotations = {
          pipelines   = var.load_cloudtrail_to_opensearch ? filesha1("${path.module}/configmaps/pipelines.yml") : filesha1("${path.module}/configmaps/pipeline.yml")
          cloudtrail  = filesha1("${path.module}/configmaps/cloudtrail.conf.tpl")
          application = filesha1("${path.module}/configmaps/application.conf.tpl")
          jvm-options = filesha1("${path.module}/configmaps/jvm.options.tpl")
          logstash    = filesha1("${path.module}/configmaps/logstash.yml")
        }
      }
      spec {
        node_selector = {
          node-group-name = var.node_group_name
        }

        toleration {
          key      = var.toleration_key
          effect   = var.toleration_effect
          operator = "Equal"
          value    = var.node_group_name
        }

        security_context {
          run_as_user  = 1000
          run_as_group = 1000
          fs_group     = 1000
        }

        container {
          image = "${var.image_url}:${var.image_tag}"
          name  = "logstash"
          resources {
            requests = {
              cpu    = var.resources.request_cpu
              memory = var.resources.request_memory
            }
            limits = {
              cpu    = var.resources.limit_cpu
              memory = var.resources.limit_memory
            }
          }
          port {
            container_port = 5044
          }
          port {
            container_port = 9600
          }
          port {
            container_port = 9700
          }

          volume_mount {
            mount_path = "/usr/share/logstash/pipeline"
            name       = "logstash"
            read_only  = true
          }
          volume_mount {
            mount_path = "/usr/share/logstash/config/pipelines.yml"
            sub_path   = "pipelines.yml"
            name       = "pipelines"
            read_only  = true
          }
          volume_mount {
            mount_path = "/usr/share/logstash/config/logstash.yml"
            sub_path   = "logstash.yml"
            name       = "logstash-main"
            read_only  = true
          }
          volume_mount {
            mount_path = "/tmp/sincedb"
            name       = "logstash-sincedb-${var.team_name}-${var.env}"
            read_only  = false
          }
          volume_mount {
            mount_path = "/usr/share/logstash/config/jvm.options"
            sub_path   = "jvm.options"
            name       = "jvm-options"
            read_only  = true
          }
        }


        container {
          image = "${var.exporter_image_url}:${var.exporter_image_tag}"
          name  = "logstash-exporter"
          resources {
            requests = {
              cpu    = var.exporterresources.request_cpu
              memory = var.exporterresources.request_memory
            }
            limits = {
              cpu    = var.exporterresources.limit_cpu
              memory = var.exporterresources.limit_memory
            }
          }
          port {
            container_port = 9198
            name           = "metrics"
          }

          args = [
            "--logstash.endpoint=http://localhost:9600"
          ]
        }

        volume {
          name = "logstash"
          config_map {
            name = var.load_cloudtrail_to_opensearch ? kubernetes_config_map.logstash-conf.metadata[0].name : kubernetes_config_map.logstash-conf-single.metadata[0].name
          }
        }
        volume {
          name = "pipelines"
          config_map {
            name = var.load_cloudtrail_to_opensearch ? kubernetes_config_map.pipelines.metadata[0].name : kubernetes_config_map.pipeline.metadata[0].name
          }
        }
        volume {
          name = "jvm-options"
          config_map {
            name = kubernetes_config_map.jvm-options.metadata[0].name
          }
        }
        volume {
          name = "logstash-main"
          config_map {
            name = kubernetes_config_map.logstash-main.metadata[0].name
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "logstash-sincedb-${var.team_name}-${var.env}"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "ebs-sc-scratch"

        resources {
          requests = {
            storage = "500Mi"
          }
        }
      }
    }
    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 0
      }
    }
  }
}

