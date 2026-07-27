resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_id
  user_data              = var.user_data
  vpc_security_group_ids = var.security_group_ids

  tags = merge(
    var.tags,
    {
      Name = "deepak-web-instance-${count.index + 1}"
    }
  )

}