vpc_cidr_block = "10.0.0.0/16"
aws_region     = "ap-south-1"

subnets = [
  {
    name = "subnet-public-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "subnet-public-2"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  }
]