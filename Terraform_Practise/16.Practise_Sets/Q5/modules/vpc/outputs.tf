output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "public_subnet_ids" {
  value       = [for name, s in aws_subnet.subnets : s.id if can(regex("public", lower(name)))]
  description = "List of public subnet IDs"
} 

output "private_subnet_ids" {
  value       = [for name, s in aws_subnet.subnets : s.id if can(regex("private", lower(name)))]
  description = "List of private subnet IDs"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat_gw.id
  description = "The ID of the NAT Gateway"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway"
}

