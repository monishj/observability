variable "team_name" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "env" {
  type = string
}

variable "pipeline_label" {
  type = string
}

variable "account_id" {
  type = string
}

variable "app-name" {
  type    = string
  default = "logstash"
}

variable "image_url" {
  type = string
}

variable "exporter_image_url" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "exporter_image_tag" {
  type = string
}
variable "node_group_name" {
  type = string
}
variable "toleration_key" {
  default = "nodeGroup"
  type    = string
}
variable "toleration_effect" {
  type    = string
  default = "NoSchedule"
}

variable "logstash_namespace" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "elasticsearch_endpoint" {
  type = string
}

variable "resources" {
  type = map(any)
}

variable "exporterresources" {
  type = map(any)
  default = {
    request_cpu    = "300m"
    request_memory = "0.5Gi"
    limit_cpu      = "1"
    limit_memory   = "1Gi"
  }
}

variable "heap-size" {
  type        = map(number)
  description = "Unit for java heap size is in GiB"
  default = {
    min = 4
    max = 4
  }
}

variable "load_cloudtrail_to_opensearch" {
  type = bool
}
