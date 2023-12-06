output "kibana" {
  value = try(module.elasticsearch[0].kibana, "Not available, since detroyed")
}

output "elasticsearch" {
  value = try(module.elasticsearch[0].elasticsearch, "Not available, since detroyed")
}

output "t-shirt-size-predefined" {
  value = local.es_cluster_config
}

output "teams-can-overwrite-attributes" {
  value = local.es_config_overwrite
}

output "this-will-be-build" {
  value = local.t-shirt-config
}

output "actual_es_config" {
  value = try(module.elasticsearch[0].es_config, "Not available, since detroyed")
}

output "ebs_calc" {
  value = try(module.elasticsearch[0].calculation_ebs, "Not available, since detroyed")
}