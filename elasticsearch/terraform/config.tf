locals {
  elasticsearch_file    = yamldecode(file("${var.configuration_path}/cloudengine/observability/elasticsearch.yaml"))
  team_name_path        = var.team_name != "automation-stack" ? "prod" : "nonprod"
  service_config        = yamldecode(file("${var.configuration_path}/${var.team_name}/aws/${local.team_name_path}/observability/service.yaml"))
  es_cluster_config     = lookup(local.elasticsearch_file.tshirt-sizes, local.service_config.opensearch_size)
  es_config_overwrite   = lookup(local.service_config, "advanced-options-overwrite-opensearch-configuration", {})
  t-shirt-config        = merge(local.es_cluster_config, local.es_config_overwrite)
  elasticsearch_version = local.elasticsearch_file.version
}
