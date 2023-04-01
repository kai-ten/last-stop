data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Use tfvars to determine whether or not to generate a VPC
module "vpc" {
  count = var.create_vpc == true ? 1 : 0

  source = "./modules/vpc"
  name     = var.name
}

module "audit_log_svc" {
  source = "./modules/audit-log"
  name   = var.name
}

module "gpt3_cc_svc" {
  source = "./modules/gpt3-cc"
  name   = var.name
}

module "last_stop" {
  source = "./modules/last-stop"

  name   = var.name
  region = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id

  audit_log_lambda_arn = module.audit_log_svc.arn
  gpt3cc_lambda_arn    = module.gpt3_cc_svc.arn

  vpc_config = {
    vpc_id             = var.create_vpc == true ? module.vpc[0].id : var.vpc.id
    vpc_cidr           = var.create_vpc == true ? module.vpc[0].cidr : var.vpc.cidr
    public_subnet_ids  = var.create_vpc == true ? module.vpc[0].public_subnet_ids : var.vpc.public_subnet_ids
    security_group_ids = var.create_vpc == true ? module.vpc[0].public_subnet_ids : var.vpc.public_subnet_ids
    public_route_table_ids    = var.create_vpc == true ? module.vpc[0].public_route_table_ids : var.vpc.public_route_table_ids
  }
}

# module "bastion" {
#   vpc_config = {
#     vpc_id             = var.create_vpc == true ? module.vpc[0].id : var.vpc.id
#     vpc_cidr           = var.create_vpc == true ? module.vpc[0].cidr : var.vpc.cidr
#     public_subnet_ids  = var.create_vpc == true ? module.vpc[0].public_subnet_ids : var.vpc.public_subnet_ids
#     security_group_ids = var.create_vpc == true ? module.vpc[0].public_subnet_ids : var.vpc.public_subnet_ids
#   }
# }
