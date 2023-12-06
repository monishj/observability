variable "configuration_path" {
  type = string
}

variable "daimler_account_id" {
  description = "The Daimler internal account name"
  type        = string
}

variable "AWS_account_id" {
  description = "The 12 number AWS account ID of the target account"
  type        = string
}

variable "team_name" {
  description = "The short name of the customer team"
  type        = string
}

variable "pipeline_label" {
  type = string
}

variable "statebucket_name" {
  type = string
}

variable "statebucket_key" {
  type = string
}

variable "image_tag" {
  type        = string
  description = "Curator image tag"
}
