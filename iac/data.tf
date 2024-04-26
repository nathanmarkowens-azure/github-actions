data "aws_caller_identity" "current" {}

data "aws_region" "primary_region" {
  provider = aws.primary_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ecr_repository" "web" {
  name = "web"
}

data "aws_ecr_image" "web" {
  repository_name = data.aws_ecr_repository.web.name
  most_recent     = true
}