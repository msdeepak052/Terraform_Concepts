output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "igw_id"  { 
  value = aws_internet_gateway.igw.id 
}

output "public_subnet_ids" {
  value = [for name, s in aws_subnet.public_subnet : s.id if can(regex("public", name))]
}