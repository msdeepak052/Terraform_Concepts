resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.available.names
  result_count = 1
}

resource "aws_instance" "deepak_ec2" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = random_shuffle.az.result[0]

  tags = merge(local.common_tags, {
    Name = "Deepak-EC2"
    }
  )
}