terraform  {
  required_version =  ">= 1.2.9, < 2.0.0"
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 5.17"
    }
    kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "~> 2.23"
    }
  }
}
