variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress security group rules"

  type = list(object({
    from_port   = number
    to_port     = number
    name        = string
    protocol    = string
    cidr        = string
    description = string
  }))
}

variable "egress_rules" {
  description = "List of egress security group rules"

  type = list(object({
    name        = string
    protocol    = string
    cidr        = string
    description = string
  }))
}