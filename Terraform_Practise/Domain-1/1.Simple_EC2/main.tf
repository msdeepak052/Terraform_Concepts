provider "aws" {
  region  = "ap-south-1"
  profile = "deepak-terraform-deployer"
}

resource "aws_instance" "first_ec2_deepak" {
  ami           = "ami-0b910d1016287a5e7"
  instance_type = "t2.micro"

}