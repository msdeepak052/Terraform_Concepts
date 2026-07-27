resource "aws_instance" "app" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  tags = merge(
    local.common_tags,
    {
      Name = "q7-${terraform.workspace}-app-${count.index + 1}"
    }
  )
}