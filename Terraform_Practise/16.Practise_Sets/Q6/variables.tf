# ============================================================
# GENERAL
# ============================================================
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# ============================================================
# VPC MODULE
# ============================================================
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "subnets" {
  type = list(object({
    name = string
    cidr = string
    az   = string
  }))
  description = "List of Public subnets to be created"
}

# ============================================================
# SECURITY GROUP MODULE (web_sg)
# ============================================================
variable "security_groups" {
  type = map(object({
    description = string
    ingress_rules = list(object({
      name      = string
      from_port = number
      to_port   = number
      protocol  = string
      cidr      = string
    }))
    egress_rules = list(object({
      name        = string
      protocol    = string
      cidr        = string
      description = string
    }))
  }))
}

# ============================================================
# EC2 MODULE
# ============================================================
variable "instance_type" {
  description = "Type of EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}
