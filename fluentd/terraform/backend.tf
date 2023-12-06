terraform {
  backend "s3" {
    region  = "eu-central-1"
    key     = "centralized-observability-logs"
    profile = "dhc-full-admin"
    encrypt = true
  } // end backend
}
