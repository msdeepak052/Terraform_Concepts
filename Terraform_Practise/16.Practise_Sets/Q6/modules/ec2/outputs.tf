output "instances" {
  value = {
    for instance in aws_instance.web :
    instance.tags["Name"] => {
      id              = instance.id
      private_ip      = instance.private_ip
      public_ip       = instance.public_ip
      subnet_id       = instance.subnet_id
      security_groups = instance.vpc_security_group_ids
      availability_zone = instance.availability_zone
    }
  }
}
