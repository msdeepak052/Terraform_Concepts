output "sg_id" {
  description = "Security Group ID"
  value       = aws_security_group.http_ssh_sg.id
}