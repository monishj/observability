# Template from https://www.terraform.io/docs/providers/aws/r/elasticsearch_domain.html

# Ingore TFsec findings in the file since elasticsearch will be sun-downed
data "aws_kms_key" "es_key" {
  key_id = "arn:aws:kms:eu-central-1:114988181552:alias/${var.daimler_account_id}-es-key-alias"
}

resource "aws_security_group" "allow-internal" {
  name        = format("%s-sg", var.domain_name)
  description = "Managed by Terraform"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }
}

#tfsec:ignore:aws-elastic-search-enforce-https tfsec:ignore:aws-elastic-search-use-secure-tls-policy
resource "aws_elasticsearch_domain" "domain" {
  domain_name           = var.domain_name
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type  = var.es_cluster_config.instance_type
    instance_count = var.es_cluster_config.instance_count

    dedicated_master_enabled = var.es_cluster_config.dedicated_master_enabled
    dedicated_master_count   = var.es_cluster_config.dedicated_master_count
    dedicated_master_type    = var.es_cluster_config.dedicated_master_type

    zone_awareness_enabled = var.es_cluster_config.zone_awareness_enabled
    zone_awareness_config {
      availability_zone_count = var.es_cluster_config.availability_zone_count
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  vpc_options {
    subnet_ids = local.subnet_ids

    security_group_ids = [
    aws_security_group.allow-internal.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
    # related to OpenSearch backward compatibility
    # reference: https://docs.aws.amazon.com/opensearch-service/latest/developerguide/rename.html
    "override_main_response_version" = "false"
  }

  access_policies = templatefile(
    "${path.module}/policies/domain-access.json",
    {
      es_domain  = var.domain_name,
      account_id = var.AWS_account_id
    }
  )

  snapshot_options {
    automated_snapshot_start_hour = 23
    # 1 am in Germany
  }

  ebs_options {
    ebs_enabled = true
    volume_size = local.ebs_size
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = data.aws_kms_key.es_key.arn
  }

  # Epic Spike
  # cognito_options {
  #   enabled = true
  #   user_pool_id = data.terraform_remote_state.authentication.outputs.daimler-github-idp-user-pool-id
  #   identity_pool_id = data.terraform_remote_state.authentication.outputs.daimler-github-idp-identity-pool-id
  #   role_arn = data.terraform_remote_state.authentication.outputs.cognito_es_role_arn
  # }

  tags = {
    Domain         = var.domain_name,
    pipeline_label = var.pipeline_label
  }

  lifecycle {
    # prevent_destroy = true
    ignore_changes = [tags]
  }
}
