output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "web_security_group_id" {
  description = "The ID of the web security group"
  value       = aws_security_group.web.id
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.db.id
}

output "logs_bucket" {
  description = "The name of the logs bucket"
  value       = aws_s3_bucket.logs.bucket
}

output "state_bucket" {
  description = "The name of the state bucket (from the backend setup)"
  value       = "The S3 bucket name used for state is defined in the backend configuration"
} 