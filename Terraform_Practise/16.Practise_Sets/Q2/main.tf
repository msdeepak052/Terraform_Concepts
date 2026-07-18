resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = merge(local.common_tags, {
    Name = "deepak-vpc"
  })

}

resource "aws_subnet" "public_subnet" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = can(regex("public", each.key))

  tags = merge(local.common_tags, {
    Name = each.key
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "deepak-igw"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "deepak-public-rt"
  })
}

resource "aws_route_table_association" "public_assoc" {
  for_each = { for s in var.subnets : s.name => s if can(regex("public", s.name)) }

  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_rt.id
}