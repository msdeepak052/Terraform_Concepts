terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # allows any 6.x (minor/patch updates), blocks a future 7.0 breaking change
    }
  }

  backend "s3" {
    bucket       = "terraform-practise-backend-deepak"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true # native S3 conditional-write locking (Terraform 1.10+) — no DynamoDB table needed
  }
}

provider "aws" {
  region = var.aws_region

}