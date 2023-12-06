provider "kubernetes" {
  config_path = "~/.kube/config"
}

terraform {
  backend "s3" {
    region     = "eu-central-1"
    key        = "logstash-service"
    profile    = "dhc-full-admin"
    encrypt    = true
  }
}

data "terraform_remote_state" "elasticsearch" {
  backend = "s3"
  config = {
    profile    = "dhc-full-admin"
    bucket     = var.statebucket_name
    region     = "eu-central-1"
    key        = "elasticsearch"
    kms_key_id = var.statebucket_key
    encrypt    = true
  }
}
