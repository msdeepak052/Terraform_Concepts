resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge( var.tags,
    {
      Name = var.vpc_name
    }
  )
  
}

resource "aws_subnet" "subnets" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = can(regex("public", each.key))

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-${each.key}"})
  
  #Future Proofing for Kubernetes Cluster
  # },
  # can(regex("public", each.key)) ? {
  #     "kubernetes.io/role/elb"           = "1"
  #     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  #   } : {
  #     "kubernetes.io/role/internal-elb"  = "1"
  #     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  #   })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-igw"
    }
  )
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-eip"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = [for name, s in aws_subnet.subnets : s.id if can(regex("public", lower(name)))][0]

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-nat-gw"
    }
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-public-rt"
    }
  )
}

resource "aws_route_table" "private-rt"{
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.cidr_block
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-private-rt"
    }
  )
}

resource "aws_route_table_association" "public-assoc" {
  for_each = { for s in var.subnets : s.name => s if can(regex("public", lower(s.name))) }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "private-assoc" {
  for_each = { for s in var.subnets : s.name => s if can(regex("private", lower(s.name))) }

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private-rt.id
}

