terraform {
  backend "s3" {
    bucket         = "web-state-storage-pq20"
    key            = "web/terraform.tfstate"
    kms_key_id     = "arn:aws:kms:us-east-1:885631303620:key/9f030e45-4958-46e8-ace8-6b06de0ccc7b"
    region         = "us-east-1"
    dynamodb_table = "web-state-lock"
    encrypt        = true
  }

  required_version = "~> 1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
}

provider "aws" {
  alias = "primary_region"

  region = "us-east-1"

  default_tags {
    tags = local.tags
  }
}
