variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created"
  type        = string

}

variable "name" {
  description = "Security Group name"
  type        = string
}

variable "description" {
  description = "Security Group description"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    name      = string
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = string
  }))

}

variable "egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    name        = string
    protocol    = string
    cidr        = string
    description = string
  }))

}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
}