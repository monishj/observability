resource "kubernetes_config_map" "logstash-conf" {
  metadata {
    name      = "logstash-conf-${var.team_name}-${var.env}"
    namespace = var.logstash_namespace
    labels = {
      pipelineid  = var.pipeline_label
      cloudtrail  = filesha1("${path.module}/configmaps/cloudtrail.conf.tpl"),
      application = filesha1("${path.module}/configmaps/application.conf.tpl")
    }
  }
  data = {
    "cloudtrail.conf" = templatefile("${path.module}/configmaps/cloudtrail.conf.tpl",
      {
        bucket                 = var.bucket_name
        elasticsearch_endpoint = var.elasticsearch_endpoint
        region                 = var.region
        account_id             = var.account_id
        team_name              = var.team_name
        stage                  = var.env
    })
    "application.conf" = templatefile("${path.module}/configmaps/application.conf.tpl",
      {
        bucket                 = var.bucket_name
        elasticsearch_endpoint = var.elasticsearch_endpoint
        region                 = var.region
        account_id             = var.account_id
        team_name              = var.team_name
        stage                  = var.env
    })
  }
}

resource "kubernetes_config_map" "logstash-conf-single" {
  metadata {
    name      = "logstash-conf-${var.team_name}-${var.env}-application-only"
    namespace = var.logstash_namespace
    labels = {
      pipelineid  = var.pipeline_label,
      application = filesha1("${path.module}/configmaps/application.conf.tpl")
    }
  }
  data = {
    "application.conf" = templatefile("${path.module}/configmaps/application.conf.tpl",
      {
        bucket                 = var.bucket_name
        elasticsearch_endpoint = var.elasticsearch_endpoint
        region                 = var.region
        account_id             = var.account_id
        team_name              = var.team_name
        stage                  = var.env
    })
  }
}

resource "kubernetes_config_map" "pipelines" {
  metadata {
    name      = "pipelines-file-${var.team_name}-${var.env}"
    namespace = var.logstash_namespace
    labels = {
      pipelineid = var.pipeline_label
      pipelines  = filesha1("${path.module}/configmaps/pipelines.yml")
    }
  }

  data = {
    "pipelines.yml" = file("${path.module}/configmaps/pipelines.yml")
  }
}

resource "kubernetes_config_map" "pipeline" {
  metadata {
    name      = "pipeline-file-${var.team_name}-${var.env}"
    namespace = var.logstash_namespace
    labels = {
      pipelineid = var.pipeline_label
      pipelines  = filesha1("${path.module}/configmaps/pipeline.yml")
    }
  }

  data = {
    "pipelines.yml" = file("${path.module}/configmaps/pipeline.yml")
  }
}

resource "kubernetes_config_map" "logstash-main" {
  metadata {
    name      = "logstash-yml-${var.team_name}-${var.env}"
    namespace = var.logstash_namespace
    labels = {
      pipelineid = var.pipeline_label
      logstash   = filesha1("${path.module}/configmaps/logstash.yml")
    }
  }

  data = {
    "logstash.yml" = file("${path.module}/configmaps/logstash.yml")
  }
}

resource "kubernetes_config_map" "jvm-options" {
  metadata {
    name      = "jvm-options-${var.team_name}-${var.env}"
    namespace = var.logstash_namespace
    labels = {
      pipelineid  = var.pipeline_label
      jvm-options = filesha1("${path.module}/configmaps/jvm.options.tpl")
    }
  }

  data = {
    "jvm.options" = templatefile("${path.module}/configmaps/jvm.options.tpl",
      {
        min_heap_size = var.heap-size.min
        max_heap_size = var.heap-size.max
    })
  }
}
