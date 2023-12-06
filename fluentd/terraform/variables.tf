variable "team_name" {
  type = string
}

variable "pipeline_label" {
  type    = string
  default = "pipeline"
}

variable "account_env" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "namespace" {
  type    = string
  default = "centralized-observability-logs"
}

variable "AWS_account_id" {
  type = string
}

variable "daimler_account_id" {
  description = "The Daimler internal account name"
  type        = string
}

variable "configuration_path" {
  type = string
}
