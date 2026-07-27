output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "List of public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "List of private subnet IDs"
}

output "nat_gateway_id" {
  value       = module.vpc.nat_gateway_id
  description = "The ID of the NAT Gateway"
}

output "internet_gateway_id" {
  value       = module.vpc.internet_gateway_id
  description = "The ID of the Internet Gateway"
}

output "instance_details" {
  value       = module.ec2.instances
  description = "Map of EC2 instance IDs and their details"
}

