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

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
  numeric = true
}

# Option 2: Using random_id to generate a unique suffix for the bucket name
# resource "random_id" "bucket" {
#   byte_length = 4
# }

# resource "aws_s3_bucket" "this" {
#   bucket = "mycompany-dev-${random_id.bucket.hex}"
# }

resource "aws_s3_bucket" "ec2-s3-bucket" {
  bucket = "${var.bucket_name}-${var.aws_region}-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"

  tags = merge(local.common_tags, {
    Name = local.bucket_name
    }
  )
}