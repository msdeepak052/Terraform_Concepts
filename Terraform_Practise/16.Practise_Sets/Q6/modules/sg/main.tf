resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "custom_ingress" {
  for_each = { for r in var.ingress_rules : "${r.name}" => r }

  security_group_id = aws_security_group.this.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr

}

resource "aws_vpc_security_group_egress_rule" "custom_egress" {
  for_each = { for r in var.egress_rules : "${r.name}" => r }

  security_group_id = aws_security_group.this.id
  ip_protocol       = each.value.protocol
  cidr_ipv4         = each.value.cidr
  description       = each.value.description
}