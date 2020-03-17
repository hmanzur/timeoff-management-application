terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "ci-gorilla-test-habib"
    key    = "terraform.tfstate"
  }
}

variable "key_name" {}

variable "bucket_name" {}

module server {
  source = "./terraform/server"

  bucket_name = var.bucket_name

  key_name = var.key_name
}