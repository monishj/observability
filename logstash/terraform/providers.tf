terraform  {
  required_version =  ">= 1.2.9, < 2.0.0"
  required_providers {
    kubernetes = {
        source  = "hashicorp/kubernetes"
        version = "~> 2.23"
    }
  }
}
