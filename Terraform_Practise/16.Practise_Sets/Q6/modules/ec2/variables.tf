variable "instance_type" {
  description = "Type of the EC2 instance"
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
}

variable "tags" {
  description = "Tags to apply to the EC2 instance"
  type        = map(string)
}

variable "security_group_ids" {
  description = "List of Security Group IDs to attach to the EC2 instance"
  type        = list(string)
}

variable "user_data" {
  description = "User data script content"
  type        = string
  default     = null
}