terraform {
  backend "s3" {
    bucket         = "web-state-storage-pq20"
    key            = "web/terraform.tfstate"
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
