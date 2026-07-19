resource "aws_security_group" "http_ssh_sg"{
	name        = "allow_http_ssh"
	description = "Allow http and ssh inbound traffic and all outbound traffic"
	vpc_id      = data.aws_vpc.selected.id
	
	tags = merge(locals.common_tags, {
			name = "http_ssh_sg_test" }
    )


}

resource "aws_vpc_security_group_ingress_rule" "custom_ingress" {
	for_each = { for r in var.ingress_rules : "${r.from_port}-${r.to_port}-${r.protocol}-${r.cidr}" => r }
	
    security_group_id = aws_security_group.http_ssh_sg.id
    from_port         = each.value.from_port
    to_port           = each.value.to_port
    ip_protocol       = each.value.protocol
    cidr_ipv4         = each.value.cidr

}

resource "aws_vpc_security_group_egress_rule" "custom_egress" {
	for_each = { for r in var.egress_rules : "${r.from_port}-${r.to_port}-${r.protocol}-${r.cidr}" => r }
	
    security_group_id = aws_security_group.http_ssh_sg.id
    ip_protocol       = each.value.protocol
    cidr_ipv4         = each.value.cidr
    description       = each.value.description
}