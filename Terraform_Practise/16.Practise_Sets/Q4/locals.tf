locals {
  bucket_name = "${var.bucket_name}-${var.aws_region}-${data.aws_caller_identity.current.account_id}-${random_string.suffix.result}"

  common_tags = {
    Environment = "Dev"
    Owner       = "Platform-Team"
  }
}