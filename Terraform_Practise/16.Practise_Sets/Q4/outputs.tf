output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.deepak_ec2.id
}

output "instance_arn" {
  description = "EC2 Instance ARN"
  value       = aws_instance.deepak_ec2.arn
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.ec2-s3-bucket.bucket
}