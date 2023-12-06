provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn     = "arn:aws:iam::${AWS_ACCOUNT_ID}:role/EKSAdmin"
    session_name = var.pipeline_label
    external_id  = var.daimler_account_id
  }
}

provider "aws" {
  region = "eu-central-1"
  assume_role {
    role_arn     = "arn:aws:iam::${AWS_ACCOUNT_ID}:role/IAMFullAccess"
    session_name = var.pipeline_label
    external_id  = var.daimler_account_id
  }
  alias = "iam-full-access"
}
