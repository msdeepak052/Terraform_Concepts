vpc_cidr   = "10.0.0.0/16"
vpc_name   = "deepak-vpc"
aws_region = "ap-south-1"

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
  },
  {
    name = "subnet-private-1"
    cidr = "10.0.3.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "subnet-private-2"
    cidr = "10.0.4.0/24"
    az   = "ap-south-1b"
  }
]