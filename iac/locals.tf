locals {
  account_id     = data.aws_caller_identity.current.account_id
  account_arn    = lower(data.aws_caller_identity.current.arn)
  primary_region = lower(data.aws_region.primary_region.name)

  name = "web"

  tags = {
    Name = "${local.name}"
    IaC  = "terraform"
  }
}