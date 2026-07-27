locals {
  common_tags = {
    Environment = terraform.workspace
    Owner       = "Platform-Team"
  }
}