variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size for this environment"
  type        = string
}

variable "instance_count" {
  description = "Number of instances for this environment"
  type        = number
  default     = 1
}