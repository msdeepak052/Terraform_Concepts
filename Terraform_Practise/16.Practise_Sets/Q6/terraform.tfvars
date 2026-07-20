aws_region = "ap-south-1"

vpc_cidr = "10.0.0.0/16"
vpc_name = "deepak-web-vpc"


subnets = [
  {
    name = "web-subnet-public-1"
    cidr = "10.0.1.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "web-subnet-public-2"
    cidr = "10.0.2.0/24"
    az   = "ap-south-1b"
  },
  {
    name = "app-subnet-private-1"
    cidr = "10.0.3.0/24"
    az   = "ap-south-1a"
  },
  {
    name = "app-subnet-private-2"
    cidr = "10.0.4.0/24"
    az   = "ap-south-1b"
  }
]


security_groups = {
  web = {
    description = "Web Security Group"

    ingress_rules = [
      {
        name      = "http"
        from_port = 80
        to_port   = 80
        protocol  = "tcp"
        cidr      = "0.0.0.0/0"
      },
      {
        name      = "ssh"
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr      = "0.0.0.0/0"
      }
    ]

    egress_rules = [
      {
        name        = "all"
        protocol    = "-1"
        cidr        = "0.0.0.0/0"
        description = "Allow all"
      }
    ]
  }
}



ami_id         = "ami-0b910d1016287a5e7"
instance_type  = "t2.micro"
key_name       = "lappynewawss"
instance_count = 1


