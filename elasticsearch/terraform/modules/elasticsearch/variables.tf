variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "elasticsearch_version" {
  type = any
}

variable "es_cluster_config" {
  type = any
}

variable "subnet_ids" {
  type = any
}

locals {
  subnet_ids = var.es_cluster_config.availability_zone_count != 3 ? slice(var.subnet_ids, 0, 2) : var.subnet_ids

  # <---------------- EBS Calculation ---------------->

  ebs_storage_size  = var.es_cluster_config.data_per_day_gb * var.retention * 1.45 / var.es_cluster_config.availability_zone_count
  assure_ebs_limits = local.ebs_storage_size > 10 && local.ebs_storage_size < var.es_cluster_config.max_ebs ? local.ebs_storage_size : (local.ebs_storage_size > 10 ? var.es_cluster_config.max_ebs : 10)
  overwrite_ebs     = lookup(var.es_cluster_config, "ebs-size", "")
  ebs_size          = ceil(local.overwrite_ebs != "" ? local.overwrite_ebs : local.assure_ebs_limits)
}

variable "pipeline_label" {
  type = string
}

variable "domain_name" {
  type = any
  description = "The Elasticserach domain name you want to monitor."
}

variable "AWS_account_id" {
  description = "The 12 number AWS account ID of the target account"
  type        = string
}

variable "daimler_account_id" {
  type = string
}

variable "namespace_name" {
  default = "monitoring"
  type    = string
}

variable "retention" {
  type = string
}

variable "curator_resources" {
  type = map(any)
  default = {
    request_cpu    = "300m"
    request_memory = "0.5Gi"
    limit_cpu      = "1"
    limit_memory   = "1Gi"
  }
}

variable "curator_image_tag" {
  type = string
  description = "Curator image tag"
}
