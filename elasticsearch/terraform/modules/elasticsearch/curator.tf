resource "kubernetes_config_map" "curator" {
  metadata {
    name      = "curator-config"
    namespace = var.namespace_name
    labels = {
      pipelineid   = var.pipeline_label
      curator_sha1 = filesha1("${path.module}/configmaps/curator.yml")
      actions_sha1 = filesha1("${path.module}/configmaps/actions.yml")
    }
  }
  data = {
    "curator.yml" = templatefile("${path.module}/configmaps/curator.yml",
      {
        elasticsearch_endpoint = aws_elasticsearch_domain.domain.endpoint
    })
    "actions.yml" = templatefile("${path.module}/configmaps/actions.yml",
      {
        retention = var.retention
    })
  }
}

resource "kubernetes_cron_job_v1" "curator-job" {
  metadata {
    name      = "curator"
    namespace = var.namespace_name
    labels = {
      pipeline_label = var.pipeline_label
    }
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 5
    schedule                      = "5 1 * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 10
    suspend                       = false
    job_template {
      metadata {}
      spec {
        template {
          metadata {
            labels = {
              pipeline_label = var.pipeline_label
            }
          }
          spec {
            container {
              name  = "curator"
              image = "registry-emea.app.corpintra.net/sip-cloudengine/curator:${var.curator_image_tag}"
#              image = "registry.app.corpintra.net/cloud-engine/curator:18-e8bc0e4d"
              args  = ["/root/.curator/actions.yml"]
              resources {
                requests = {
                  cpu    = var.curator_resources.request_cpu
                  memory = var.curator_resources.request_memory
                }
                limits = {
                  cpu    = var.curator_resources.limit_cpu
                  memory = var.curator_resources.limit_memory
                }
              }
              volume_mount {
                mount_path = "/root/.curator"
                name       = "config"
              }
            }
            restart_policy = "OnFailure"
            volume {
              name = "config"
              config_map {
                name = kubernetes_config_map.curator.metadata[0].name
              }
            }
          }
        }
      }
    }
  }
}
