provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn     = "arn:aws:iam::${var.AWS_account_id}:role/ElasticsearchFullAccess"
    session_name = var.pipeline_label
    external_id  = var.daimler_account_id
  }
}

terraform {
  backend "s3" {
    region     = "eu-central-1"
    key        = "elasticsearch"
    profile    = "dhc-full-admin"
    encrypt    = true
  } // end backend
}

################################
# Remote State
################################

data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    profile    = "dhc-full-admin"
    bucket     = var.statebucket_name
    region     = "eu-central-1"
    key        = "networking"
    kms_key_id = var.statebucket_key
    encrypt    = true
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
