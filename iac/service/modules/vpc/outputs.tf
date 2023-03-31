output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}

output "vpc_private_subnet_cidrs" {
  value = module.vpc.private_subnets_cidr_blocks
}

output "integration_security_group_id" {
  value = module.integration_security_group.security_group_id
}
