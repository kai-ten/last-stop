data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}

# Example - https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/examples/complete-vpc/main.tf
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.name}-${terraform.workspace}"
  cidr = "10.0.0.0/16"

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet("10.0.0.0/16", 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet("10.0.0.0/16", 8, k + 3)]

  enable_dns_hostnames = true
  enable_dns_support   = true
}
