module "vpc" {
  source = "./modules/vpc"

  cidr_block = var.vpc_cidr
  vpc_name   = var.vpc_name
  tags       = local.common_tags
  subnets    = var.subnets
}