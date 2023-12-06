data "aws_vpc" "selected" {
  id = data.terraform_remote_state.networking.outputs.vpc-id
}

module "elasticsearch" {
  source = "./modules/elasticsearch"

  count = lookup(local.service_config, "disable_elasticsearch", false) == true ? 0 : 1

  #configuration_path     = var.configuration_path
  AWS_account_id        = var.AWS_account_id
  daimler_account_id    = var.daimler_account_id
  pipeline_label        = var.pipeline_label
  domain_name           = "es-${var.team_name}"
  vpc_id                = data.aws_vpc.selected.id
  vpc_cidr_block        = data.aws_vpc.selected.cidr_block
  elasticsearch_version = local.elasticsearch_version
  es_cluster_config     = local.t-shirt-config
  subnet_ids            = data.terraform_remote_state.networking.outputs.aux-services-subnet-ids
  retention             = local.service_config.log_retention_in_opensearch
  curator_image_tag     = var.image_tag
}

moved {
  from = module.elasticsearch
  to   = module.elasticsearch[0]
}
