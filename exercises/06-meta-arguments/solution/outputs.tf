# VPC Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

# Subnet Outputs
output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = aws_subnet.main[*].id
}

output "subnet_cidr_blocks" {
  description = "CIDR blocks of the created subnets"
  value       = aws_subnet.main[*].cidr_block
}

# EC2 Instance Outputs
output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = aws_instance.web[*].id
}

output "instance_public_ips" {
  description = "Public IPs of the created EC2 instances"
  value       = aws_instance.web[*].public_ip
}

# IAM User Outputs
output "developer_user_arns" {
  description = "ARNs of the created developer IAM users"
  value       = { for user in aws_iam_user.developers : user.name => user.arn }
}

output "operator_user_arns" {
  description = "ARNs of the created operator IAM users"
  value       = { for user in aws_iam_user.operators : user.name => user.arn }
}

# S3 Bucket Outputs
output "data_bucket_arns" {
  description = "ARNs of the created data S3 buckets"
  value       = { for bucket in aws_s3_bucket.data : bucket.bucket => bucket.arn }
}

output "backup_bucket_arn" {
  description = "ARN of the backup S3 bucket in secondary region"
  value       = aws_s3_bucket.backup.arn
}

# RDS Instance Output
output "database_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

# Security Group Output
output "security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web.id
}

# Availability Zones Output
output "available_azs" {
  description = "List of available Availability Zones"
  value       = data.aws_availability_zones.available.names
} 