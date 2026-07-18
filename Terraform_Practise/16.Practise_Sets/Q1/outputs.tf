output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}

output "instance_arn" {
  description = "EC2 Instance ARN"
  value       = aws_instance.web.arn
}

output "public_ip" {
  description = "Public IP Address"
  value       = aws_instance.web.public_ip
}

output "private_ip" {
  description = "Private IP Address"
  value       = aws_instance.web.private_ip
}

output "public_dns" {
  description = "Public DNS Name"
  value       = aws_instance.web.public_dns
}

output "private_dns" {
  description = "Private DNS Name"
  value       = aws_instance.web.private_dns
}

output "availability_zone" {
  description = "Availability Zone"
  value       = aws_instance.web.availability_zone
}

output "subnet_id" {
  description = "Subnet ID"
  value       = aws_instance.web.subnet_id
}

output "vpc_security_group_ids" {
  description = "Attached Security Groups"
  value       = aws_instance.web.vpc_security_group_ids
}

output "instance_state" {
  description = "Current EC2 State"
  value       = aws_instance.web.instance_state
}

output "tags" {
  description = "Tags applied to EC2"
  value       = aws_instance.web.tags
}