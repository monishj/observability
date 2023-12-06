locals {
  managed_accounts_config = yamldecode(file("${var.configuration_path}/cloudengine/managed-accounts.yaml"))
  elasticsearch           = yamldecode(file("${var.configuration_path}/${var.team_name}/aws/${var.account_env}/observability/service.yaml"))

  #<------------------------------------------------>

  team_accounts             = { for k, v in local.managed_accounts_config : k => v if v.team_name == var.team_name }
  automation_stack_accounts = { for k, v in local.managed_accounts_config : k => v if v.team_name == "automation-stack" || v.team_name == "test" }
  logstash_accounts         = var.team_name == "automation-stack" ? local.automation_stack_accounts : local.team_accounts
  disable_elasticsearch     = lookup(local.elasticsearch, "disable_elasticsearch", false) == true
}

variable "configuration_path" {
  type = string
}

variable "account_env" {
  type = string
}

variable "team_name" {
  type = string
}

variable "pipeline_label" {
  type    = string
  default = "pipeline"
}

variable "node_group_name" {
  type    = string
  default = "monitoring-ng"
}

variable "image-url" {
  type    = string
  default = "registry-emea.app.corpintra.net/sip-cloudengine/logstash"
}

variable "exporter-image-url" {
  type    = string
  default = "registry-emea.app.corpintra.net/amazoncache/bitnami/logstash-exporter"
}

variable "image-tag" {
  type = string
}

variable "exporter-image-tag" {
  type    = string
  default = "7.3.0"
}

variable "logstash_namespace" {
  type    = string
  default = "monitoring"
}

variable "statebucket_name" {
  type = string
}

variable "statebucket_key" {
  type = string
}
