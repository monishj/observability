module "logstash" {
  for_each                      = local.disable_elasticsearch ? {} : local.logstash_accounts
  source                        = "./modules/logstash"
  team_name                     = each.value.team_name
  env                           = each.value.stage
  logstash_namespace            = var.logstash_namespace
  account_id                    = each.value.aws_account_id
  pipeline_label                = var.pipeline_label
  image_url                     = var.image-url
  exporter_image_url            = var.exporter-image-url
  image_tag                     = var.image-tag
  exporter_image_tag            = var.exporter-image-tag
  node_group_name               = var.node_group_name
  elasticsearch_endpoint        = data.terraform_remote_state.elasticsearch.outputs.elasticsearch
  bucket_name                   = format("%s-%s-%s-logbucket", each.value.team_name, each.value.stage, each.value.aws_account_id)
  resources                     = lookup(local.elasticsearch.logstash_resources, each.value.stage)
  load_cloudtrail_to_opensearch = local.elasticsearch.load_cloudtrail_to_opensearch
}
