output "kibana" {
  value = aws_elasticsearch_domain.domain.kibana_endpoint
}

output "elasticsearch" {
  value = aws_elasticsearch_domain.domain.endpoint
}

output "calculation_ebs" {
  value = local.ebs_storage_size
}

output "actual_ebs" {
  value = local.ebs_size
}

output "es_config" {
  value = aws_elasticsearch_domain.domain.cluster_config
}