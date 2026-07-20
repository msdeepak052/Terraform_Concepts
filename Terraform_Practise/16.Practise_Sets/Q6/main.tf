# ============================================================
# VPC MODULE — network foundation (VPC, public/private subnets,
# Internet Gateway, NAT Gateway, route tables)
# ============================================================
module "vpc" {
  source = "./modules/vpc"

  cidr_block = var.vpc_cidr
  vpc_name   = var.vpc_name
  tags       = local.common_tags
  subnets    = var.subnets
}

# ============================================================
# SECURITY GROUP MODULE — web tier ingress/egress rules
# ============================================================
module "web_sg" {
  source = "./modules/sg"

  for_each = var.security_groups

  name          = each.key
  description   = each.value.description
  vpc_id        = module.vpc.vpc_id
  ingress_rules = each.value.ingress_rules
  egress_rules  = each.value.egress_rules
  tags          = local.common_tags

  depends_on = [module.vpc]
}

# ============================================================
# EC2 MODULE — web server instance(s), bootstrapped via user_data
# ============================================================
module "ec2" {
  source = "./modules/ec2"

  instance_type  = var.instance_type
  ami            = var.ami_id
  key_name       = var.key_name
  subnet_id      = module.vpc.public_subnet_ids[0]
  instance_count = var.instance_count
  tags           = local.common_tags
  security_group_ids = [
    module.web_sg["web"].security_group_id
  ]
  user_data = file("${path.module}/userdata/httpd_install.sh")

  depends_on = [module.web_sg]
}
