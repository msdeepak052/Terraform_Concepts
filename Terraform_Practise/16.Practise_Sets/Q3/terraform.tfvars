ingress_rules = [
  {
    from_port  = 22
    to_port    = 22
    protocol   = "tcp"
    cidr       = "10.0.0.0/16"
    description = "SSH access"
  },
  {
    from_port  = 80
    to_port    = 80
    protocol   = "tcp"
    cidr       = "0.0.0.0/0"
    description = "HTTP access"
  }
]

egress_rules = [
  {
    protocol    = "-1"
    cidr        = "0.0.0.0/0"
    description = "Allow all outbound traffic"
  }
]